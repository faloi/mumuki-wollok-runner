class WollokTestHook < WollokHook

  def transform_response(result)
    if errored? result
      [extract_compilation_errors(result), :errored]
    elsif result['tests'].present?
      [result['tests'].map { |it| transform_test_result(it) }]
    elsif result['runtimeErrors'].present?
      [result['runtimeErrors'].to_s, :failed]
    elsif result['consoleOutput'].present?
      [result['consoleOutput'] || '', :failed]
    else
      [result.to_s, :errored]
    end
  end

  def transform_test_result(result)
    [result['name'], result['state'] == 'passed' ? :passed : :failed, result['error'].try{|i|i['stackTrace']}]
  end

  def program_type
    'wtest'
  end

  def compile_program(r)
    <<WLK
object mumukiConsole {
  method println(anObject) {
     console.println(anObject)
  }
}

#{r.extra}
#{r.content}
#{r.test}
WLK
  end

end