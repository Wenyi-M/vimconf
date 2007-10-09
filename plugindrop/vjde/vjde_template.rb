
module Vjde #{{{1
    class VjdeTemplate #{{{2
        ParaStruct = Struct.new("ParaStruct",:name,:desc,:value)
        attr_reader:paras
        attr_reader:name
        attr_accessor:desc
        attr_accessor:lines
        attr_reader:manager
        attr_reader:entities
        def initialize(n,m)
            @manager = m
            @paras={}
            @name=n
            @lines=[]
            @entities={}
            @desc=""
        end
        def add_para(n,d) 
            @paras[n]= ParaStruct.new(n,d)
        end
        def set_para(n,v)
            @paras[n].value = v if @paras.has_key?(n)
        end
        def each_line 
            @lines.each { |l|
                if l[/^\s*%.*%\s*$/]!=nil
                    name = l[/%.*%/][1..-2]
                    entity = nil
                    if @entities.has_key?(name)
                        entity = @entities[name]
                    else
                        entity = @manager.getTemplate(name)
                    end
                    entity.each_line { |l| yield(l) } if entity!=nil
                    next
                end
                l.gsub!(/%\{([^}]+)\}/) { |p|
                    if @paras.has_key?($1)
                        @paras[$1].value
                    else
                        eval($1)
                    end
                }
                yield(l)
            }
        end
        def each_para 
            @paras.each_value { |p| yield(p) }
            @lines.each { |l|
                if l[/^\s*%.*%\s*$/]!=nil
                    name = l[/%.*%/][1..-2]
                    entity = @manager.getTemplate(name)
                    entity.each_para { |p|
                        if @paras.has_key?(p.name)
                            entity.set_para(p.name,@paras[p.name].value)
                            next
                        else
                            yield(p)
                        end
                    }
                    @entities[name]=entity
                end
            }
        end
        def to_s
            @name + ":"+@desc
        end
    end
    class VjdeTemplateManager #{{{2
        attr_reader:current
        attr_reader:indexs
        TemplateIndex = Struct.new("TemplateIndex",:name,:desc,:pos,:file)
        RE_TEMPLATE=/^temp/
        RE_BODY=/^body/
        RE_END=/^endt/
        RE_PARA=/^para/
        RE_TEMP_SPLIT=/^temp[a-z]*\s+(\w+)(\s+.*)$/
        RE_PARA_SPLIT=/^para[a-z]*\s+(\w+)(\s+.*)$/
        def initialize(f=nil)
            @current=nil
            @indexs = []
            load_index(f) if f!= nil
        end
        def add_file(t)
            load_index(t)
        end
        def each
            @indexs.each { |i| yield(i.name,i.desc) }
        end
        def findIndex(name) 
            @indexs.find { |i| i.name==name } 
        end
        def getTemplate(index_name)
            #return current if current!=nil && current.name==index_name
            index = findIndex(index_name)
            return nil if index == nil
            return nil unless FileTest.exist?(index.file)
            temp = nil
            tpf = File.open(index.file)
            tpf.seek(index.pos)
            intemplate = false
            tpf.each_line { |l|
                next if l[0,1]=='/'
                case l
                when RE_TEMPLATE
                    arr = l.scan(RE_TEMP_SPLIT)
                    temp =  VjdeTemplate.new(arr[0][0],self)
                    temp.desc=arr[0][1]
                when RE_END
                    break
                when RE_BODY
                    intemplate = true
                when RE_PARA
                    arr = l.scan(RE_PARA_SPLIT)
                    temp.add_para(arr[0][0],arr[0][1])
                else
                    l[0,1]='' if l[0,1]=='\\'
                    temp.lines<<l if intemplate
                end
            }
            tpf.close()
            @current = temp
            @current
        end
        private
        def load_index(f)
            return unless FileTest.exist?(f)
            tpf = File.open(f)
            pos = 0
            tpf.each_line { |l|
                next if l[0,1]=='/'
                case l
                when RE_TEMPLATE
                    arr = l.scan(RE_TEMP_SPLIT)
                    @indexs << TemplateIndex.new(arr[0][0],arr[0][1],pos,f)
                end
                pos = tpf.pos
            }
            tpf.close
        end
    end
    $vjde_template_manager = nil
end #}}}1
#str = "template NewClass "
#str = "template NewClass this is a new class template"
#puts str.scan(/^temp[a-z]+\s+(\w+)\s+(.*)$/)

#tmps = Vjde::VjdeTemplateManager.new
#tmps.load('plugin\vjde\tlds\java.template')
#tmps.each { |p|
    #puts p.name
    #p.lines.each { |l| puts l }
#}


#tmps = Vjde::VjdeTemplateManager.new('plugin\vjde\tlds\java.template')
#template = tmps.getTemplate('NewClass')
#template.paras.each_value { |p|
    #puts p.name
    #puts p.desc
#}
#template.set_para('class','Wfc1')
#template.set_para('package','com.wfc.pkg')
#template.each_line { |l| puts l }

#tmps = Vjde::VjdeTemplateManager.new('plugin/vjde/tlds/java.vjde')
#template = tmps.getTemplate('NewClass')
#template.each_para { |p| 
    #puts " Inpute the value of #{p.name}\t#{p.desc}:"
    #template.set_para(p.name,gets().strip!)
#}
#template.each_line { |l| puts l }

#paras={'type'=>'interface','name'=>'Wfc'}
#str='public #{type} #{name} {'
#str.gsub!(/#\{([^}]+)\}/) { |p|
   #eval("paras[\""+$1+"\"]") 
#}
#puts str

# vim: fdm=marker
