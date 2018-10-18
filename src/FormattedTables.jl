module FormattedTables

using Format
using Tables

"""
    FormattedTables.write(
        file::Union{IO,String},
        table;
        delim = ' ',
        column_names=Tables.schema(table).names,
        formatters=Dict(name=>"" for name in column_names),
        header_fmt=Dict(name=>"" for name in column_names),
    )
Write a [Tables.jl interface input](https://github.com/JuliaData/Tables.jl)
to a stream or a named file using the [format specifiers](https://github.com/JuliaString/Format.jl)
provided via the `formatters` keyword argument. The `formatters` argument must
be a dictionary, named tuple, or similar collection that can be indexed using
the column names of the table.

Keyword arguments include:
* `delim`: A delimiter to print between list items.
* `column_names`: An iterable collection containing, in order, the names (as
  `Symbol`s) of the columns of the table to be written.
* `formatters`: A dictionary, named tuple, or similar collection that maps 
  the the names (`Symbol`s) of the columns to be written to a `Format.FormatSpec`
  used to format the column.
* `header_fmt`: A dictionary, named tuple, or similar collection that maps 
  the the names (`Symbol`s) of the columns to be written to a `Format.FormatSpec`
  used to format the column headers. Set to `nothing` to skip writing column
  headers.
"""
function write end

function write(
    filename::String,
    table;
    delim = ' ',
    column_names=Tables.schema(table).names,
    formatters=Dict(name=>"" for name in column_names),
    header_fmt=Dict(name=>"" for name in column_names),
)
    open(filename, "w") do f
        write(f, table, delim=delim, column_names=column_names, formatters=formatters, header_fmt=header_fmt)
    end
end

function write(
    io::IO,
    table;
    delim = " ",
    column_names=Tables.schema(table).names,
    formatters=Dict(name=>FormatSpec("") for name in column_names),
    header_fmt=Dict(name=>FormatSpec("") for name in column_names),
)
    if header_fmt !== nothing
        n = 0
        for name in column_names
            printfmt(io, header_fmt[name], string(name))
            n+=1
            if n<length(column_names)
                print(io, delim)
            end
        end
        print(io, '\n')
    end
    for row in Tables.rows(table)
        n = 0
        for name in column_names
            printfmt(io, formatters[name], getproperty(row, name))
            n+=1
            if n<length(column_names)
                print(io, delim)
            end
        end
        print(io, '\n')
    end
    nothing
end

end # module
