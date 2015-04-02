module ApplicationHelper  
# Возвращает полный заголовок зависящий от страницы # Документирующий коментарий
  def full_title(page_title)                          # Определение метода
    base_title = ""  # Назначение переменной
    if page_title.blank?                              # Булевый тест
      base_title                                      # Явное возвращение
    else
      "#{base_title} | #{page_title}"                 # Интерполяция строки
    end
  end
end
