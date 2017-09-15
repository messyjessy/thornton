Class C80Estate::Sevent < ActiveRecord::Base

# File 'app/models/c80_estate/sevent.rb', line 16

def self.ecoef(area_id: nil, prop_id: nil, atype_id: nil, start_date: nil, end_date: nil)
  # start_date: строка вида 2015-12-12

  result = {}

  # unless end_date.present?
  #   end_date = Time.now.utc #.to_s(:db)
  # end
  # unless start_date.present?
  #   if prop_id.present?
  #     start_date =
  #   end
  # end

  # произведём выборку из базы в list согласно параметрам
  list = []

  # если ничего не подано - выбираем всё и считаем среднее
  if area_id.nil? && prop_id.nil? && atype_id.nil? && start_date.nil? && end_date.nil?

    # в result соберём хэш, где ключ - area_id
    # а значение - объект вида {time_free, time_busy} -
    # время, сколько площадь была в аренде или была свободна

    # раскидаем все sevents по area_id related спискам
    self.all.each do |sevent|
      aid = sevent.area_id
      unless result[aid].present?
        result[aid] = {
            time_free: 0,
            time_busy: 0,
            ecoef: 0,
            start_date:self.first.created_at,
            end_date:Time.now,
            sevents: []
        }
      end
      result[aid][:sevents] << sevent
    end

    # теперь пробежимся по спискам площадей и посчитаем время
    result.each_key do |area_id|

      # фиксируем area
      a = result[area_id]

      # считаем free busy time
      t = self._calc_busy_time(a)
      a[:time_free] = t[:time_free]
      a[:time_busy] = t[:time_busy]
      a[:ecoef] = t[:ecoef]

    end

    # теперь имеется result в котором посчитаны time_free и time_busy
    # каждой площади
    # пробежимся по нему и посчитаем коэф-ты
    k = 0
    summ = 0
    result.each_key do |area_id|
      a = result[area_id]
      # a[:ecoef] = a[:time_busy] / (a[:time_busy] + a[:time_free])
      Rails.logger.debug "<ecoef> area_id=#{area_id}, time_free=#{a[:time_free]}, time_busy=#{a[:time_busy]}, ecoef=#{a[:ecoef]}"
      k += 1
      summ += a[:ecoef]
    end

    result[:average_value] = sprintf "%.2f%", summ/k*100
    result[:comment] = "<abbr title='Период рассчёта эффективности: с момента самого первого известного события до текущего дня'>C #{Time.at(self.first.created_at).strftime('%Y/%m/%d')} по #{Time.now.year}/#{sprintf "%02d", Time.now.month}/#{sprintf "%02d", Time.now.day}</abbr>"
    result[:abbr] = 'Среднее значение коэф-та эффективности для всех площадей за весь период. Эффективность - это число b/N, где b - кол-во дней которые площадь была занята (за указанный период), N - всего дней в указанном периоде'
    result[:title] = 'Статистика - Все площади'
    result[:props] = [
        {tag:'all_areas_count', val: "Площадей всего: #{Area.all.count}"},
        {tag:'free_areas_count', val: "Площадей свободно: #{Area.free_areas.count}"},
        {tag:'busy_areas_count', val: "Площадей занято: #{Area.busy_areas.count}"}
    ]


  # если фильтруем по area
  elsif area_id.present?

    # фиксируем area
    area = Area.find(area_id)

    # обозначим диапазон фильтрации
    area_created_at = Time.at(area.created_at)
    time_now = Time.now
    Rails.logger.debug("area_created_at = #{area_created_at}")
    Rails.logger.debug("time_now = #{time_now}")

    # если подана нижняя граница диапазона и она позже, чем время создания Площади,
    # выравниваем период рассчета коэф-та по этой нижней границе диапазона
    if start_date.present?
      start_date_tt = Time.parse(start_date)
      if start_date_tt > area_created_at
        used_start_date = start_date_tt
        Rails.logger.debug("start_date: используем аргумент: #{start_date_tt}")
      else
        used_start_date = area_created_at
        Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
      end
    else
      used_start_date = area_created_at
      Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
    end
    used_start_date_str = used_start_date.strftime('%Y/%m/%d')

    if end_date.present?
      end_date_tt = Time.parse(end_date)
      if end_date < time_now
        used_end_date = end_date_tt
        Rails.logger.debug("end_date: используем аргумент: #{end_date_tt}")
      else
        used_end_date = time_now
        Rails.logger.debug("end_date: используем текущее время")
      end
    else
      used_end_date = time_now
      Rails.logger.debug("end_date: используем текущее время")
    end
    used_end_date_str = used_end_date.strftime('%Y/%m/%d')

    Rails.logger.debug("start_date = #{start_date}; end_date = #{end_date}; used_start_date = #{used_start_date}; used_end_date = #{used_end_date}")
    # sevents = self.where(:area_id => area_id).where(:created_at => used_start_date..used_end_date)
    sevents = self.where(:area_id => area_id).where("created_at BETWEEN ? AND ?", used_start_date, used_end_date)

    # if atype_id.present?
    #   sevents = sevents.where(:atype_id => atype_id)
    # end

    # если в этот промежуток небыло событий - значит промежуток целиком попал в какое-то событие
    # найдем его
    # заодно поднимем вспомогательный флаг, который обработаем во view
    mark_whole = false
    if sevents.count == 0
      sevents = [self.where(:area_id => area_id).where("created_at < ?", used_start_date).last]
      mark_whole = true
      # sevents.each do |se|
      #   Rails.logger.debug "\t\t\t #{used_start_date - se.created_at}"
      # end
    end

    t = _calc_busy_time({
                            time_free: 0,
                            time_busy: 0,
                            ecoef: 0,
                            sevents: sevents,
                            start_date:used_start_date,
                            end_date:used_end_date
                        })

    result[area_id] = {
        time_free: t[:time_free],
        time_busy: t[:time_busy],
        ecoef: t[:ecoef],
        # sevents: self.where(:area_id => area_id)
        sevents: sevents
    }

    result[:average_value] = sprintf "%.2f%", result[area_id][:ecoef]*100
    result[:comment] = "<abbr title='Период рассчёта коэф-та эффективности'>C #{used_start_date_str} по #{used_end_date_str}</abbr>"
    result[:abbr] = 'Коэф-т эффективности площади за указанный период. Эффективность - это число b/N, где b - кол-во дней которые площадь была занята (за указанный период), N - всего дней в указанном периоде'
    result[:title] = "Статистика - площадь '#{area.title}'"
    result[:graph] = _parse_for_js_graph(sevents)

    if mark_whole
      if t[:time_busy] == 0
        t[:time_free] = used_end_date - used_start_date
      end
    end

    result[:props] = [
        { tag: 'title', val: "Площадь: #{area.title}" },
        { tag: 'atype', val: "Тип: #{area.atype_title}" },
        { tag: 'born_date', val: "Дата создания: #{area.created_at.in_time_zone('Moscow').strftime('%Y/%m/%d')}" },
        { tag: 'busy_time', val: "<abbr title='В указанный период'>Времени занята</abbr>: #{time_duration(t[:time_busy])}" },
        { tag: 'free_time', val: "<abbr title='В указанный период'>Времени свободна</abbr>: #{time_duration(t[:time_free])}" },
        { tag: 'all_time', val: "<abbr title='В указанный период'>Времени всего</abbr>: #{time_duration(t[:time_busy] + t[:time_free])}" },
        { tag: 'assigned_person_title', val: "Ответственный: #{area.assigned_person_title}" },
        { tag: 'property_title', val: "Объект: #{area.property_title}" }
    ]

    # if atype_id.present?
    #   result[:props] << {tag: 'atype_filter', val: "Фильтр по типу площади: #{ Atype.find(atype_id).title }"}
    # end

  elsif prop_id.present?

  end

  result

end

# File 'app/models/c80_estate/sevent.rb', line 210

def area_title
  res = "-"
  if area.present?
    res = area.title
  end
  res
end

# File 'app/models/c80_estate/sevent.rb', line 218

def atype_title
  res = "-"
  if atype.present?
    res = atype.title
  end
  res
end

# File 'app/models/c80_estate/sevent.rb', line 226

def property_title
  res = "-"
  if property.present?
    res = property.title
  end
  res
end

# File 'app/models/c80_estate/sevent.rb', line 234

def astatus_title
  res = "-"
  if astatus.present?
    res = astatus.title
  end
  res
end

# File 'app/models/c80_estate/sevent.rb', line 242

def auser_title
  res = "-"
  if auser.present?
    res = auser.email
  end
  res
end

