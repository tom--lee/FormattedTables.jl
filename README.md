# FormattedTables

A Julia package for formatting tabular data.

[![Build Status](https://travis-ci.org/tom--lee/FormattedTables.jl.svg?branch=master)](https://travis-ci.org/tom--lee/FormattedTables.jl)

This package contains a single function, `FormattedTables.write`, used to write 
tabular data stored in an object supporting the [Tables.jl 
interface](https://github.com/JuliaData/Tables.jl). For each column, a 
`FormatSpec`, provided by [the Format.jl 
package](https://github.com/JuliaString/Format.jl), can be used to format the 
column.


# Usage
```julia
FormattedTables.write(
    file::Union{IO,String},
    table;
    delim = ' ',
    column_names=Tables.schema(table).names,
    formatters=Dict(name=>"" for name in column_names),
    header_fmt=Dict(name=>"" for name in column_names),
)
```
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
* `formatters`: A dictionary, named tuple, or similar collection that maps 
  the the names (`Symbol`s) of the columns to be written to a `Format.FormatSpec`
  used to format the column.
* `header_fmt`: A dictionary, named tuple, or similar collection that maps 
  the the names (`Symbol`s) of the columns to be written to a `Format.FormatSpec`
  used to format the column headers. Set to `nothing` to skip writing column
  headers.

# Example

```julia
julia> using FormattedTables

julia> using DataFrames

julia> using Format

julia> using CSV

julia> csv = IOBuffer("""name,height,age
       Alice,1.60,21
       Bob,1.83,40
       Claire,1.75,31
       David,1.50,25
       Edith,1.68,30
       """)
IOBuffer(data=UInt8[...], readable=true, writable=false, seekable=true, append=false, size=85, maxsize=Inf, ptr=1, mark=-1)

julia> data = CSV.read(csv) |> DataFrame
5×3 DataFrame
│ Row │ name    │ height   │ age    │
│     │ String  │ Float64  │ Int64  │
├─────┼─────────┼──────────┼────────┤
│ 1   │ Alice   │ 1.6      │ 21     │
│ 2   │ Bob     │ 1.83     │ 40     │
│ 3   │ Claire  │ 1.75     │ 31     │
│ 4   │ David   │ 1.5      │ 25     │
│ 5   │ Edith   │ 1.68     │ 30     │

julia> b = PipeBuffer()
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=false, append=true, size=0, maxsize=Inf, ptr=1, mark=-1)

julia> FormattedTables.write(b, data)

julia> result = String(take!(b))
"name height age\nAlice 1.6 21\nBob 1.83 40\nClaire 1.75 31\nDavid 1.5 25\nEdith 1.68 30\n"

julia> println(result)
name height age
Alice 1.6 21
Bob 1.83 40
Claire 1.75 31
David 1.5 25
Edith 1.68 30


julia> const fs = FormatSpec
FormatSpec

julia> formatters = (
       name=fs("10s"),
       height=fs("7.2f"),
       age=fs("3d"),
       )
(name = FormatSpec
  cls   = s
  typ   = s
  fill  =
  align = <
  sign  = -
  width = 10
  prec  = -1
  ipre  = false
  zpad  = false
  tsep  = false
, height = FormatSpec
  cls   = f
  typ   = f
  fill  =
  align = >
  sign  = -
  width = 7
  prec  = 2
  ipre  = false
  zpad  = false
  tsep  = false
, age = FormatSpec
  cls   = i
  typ   = d
  fill  =
  align = >
  sign  = -
  width = 3
  prec  = -1
  ipre  = false
  zpad  = false
  tsep  = false
)

julia> header_fmt = (
       name=fs("10s"),
       height=fs(">7s"),
       age=fs(">3s"),
       )
(name = FormatSpec
  cls   = s
  typ   = s
  fill  =
  align = <
  sign  = -
  width = 10
  prec  = -1
  ipre  = false
  zpad  = false
  tsep  = false
, height = FormatSpec
  cls   = s
  typ   = s
  fill  =
  align = >
  sign  = -
  width = 7
  prec  = -1
  ipre  = false
  zpad  = false
  tsep  = false
, age = FormatSpec
  cls   = s
  typ   = s
  fill  =
  align = >
  sign  = -
  width = 3
  prec  = -1
  ipre  = false
  zpad  = false
  tsep  = false
)

julia> b = PipeBuffer()
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=false, append=true, size=0, maxsize=Inf, ptr=1, mark=-1)

julia> FormattedTables.write( b, data, delim = " ", formatters = formatters, header_fmt = header_fmt)

julia> result = String(take!(b))
"name        height age\nAlice         1.60  21\nBob           1.83  40\nClaire        1.75  31\nDavid         1.50  25\nEdith         1.68  30\n"

julia> println(result)
name        height age
Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30


julia> b = PipeBuffer()
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=false, append=true, size=0, maxsize=Inf, ptr=1, mark=-1)

julia> FormattedTables.write( b, data, delim = " ", column_names=(:age, :name), formatters = formatters, header_fmt = header_fmt)

julia> result = String(take!(b))
"age name      \n 21 Alice     \n 40 Bob       \n 31 Claire    \n 25 David     \n 30 Edith     \n"

julia> println(result)
age name
 21 Alice
 40 Bob
 31 Claire
 25 David
 30 Edith

julia> b = PipeBuffer()
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=false, append=true, size=0, maxsize=Inf, ptr=1, mark=-1)

julia> FormattedTables.write( b, data, delim = " ", formatters = formatters, header_fmt = nothing)

julia> result = String(take!(b))
"Alice         1.60  21\nBob           1.83  40\nClaire        1.75  31\nDavid         1.50  25\nEdith         1.68  30\n"

julia> println(result)
Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30


julia> FormattedTables.write("test-out.dat", data, delim = " ", formatters = formatters, header_fmt = header_fmt)

julia> result = open(x->read(x,String), "test-out.dat",)
"name        height age\nAlice         1.60  21\nBob           1.83  40\nClaire        1.75  31\nDavid         1.50  25\nEdith         1.68  30\n"

julia> println(result)
name        height age
Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30
