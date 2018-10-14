
using FormattedTables

using DataFrames
using Format
using CSV
using Test

csv = IOBuffer("""name,height,age
Alice,1.60,21
Bob,1.83,40
Claire,1.75,31
David,1.50,25
Edith,1.68,30
""")

data = CSV.read(csv) |> DataFrame

b = PipeBuffer()
FormattedTables.write(b, data)
result = String(take!(b))
println(result)
expected="""name height age
Alice 1.6 21
Bob 1.83 40
Claire 1.75 31
David 1.5 25
Edith 1.68 30
"""
@test expected == result

const fs = FormatSpec

formatters = (
name=fs("10s"),
height=fs("7.2f"),
age=fs("3d"),
)

header_fmt = (
name=fs("10s"),
height=fs(">7s"),
age=fs(">3s"),
)

b = PipeBuffer()
FormattedTables.write( b, data, delim = " ", formatters = formatters, header_fmt = header_fmt)
result = String(take!(b))
println(result)
expected = """name        height age
Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30
"""
@test expected == result

b = PipeBuffer()
FormattedTables.write( b, data, delim = " ", column_names=(:age, :name), formatters = formatters, header_fmt = header_fmt)
result = String(take!(b))
println(result)
expected = """age name      
 21 Alice     
 40 Bob       
 31 Claire    
 25 David     
 30 Edith     
"""
@test expected == result


b = PipeBuffer()
FormattedTables.write( b, data, delim = " ", formatters = formatters, header_fmt = nothing)
result = String(take!(b))
println(result)
expected = """Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30
"""
@test expected == result

FormattedTables.write("test-out.dat", data, delim = " ", formatters = formatters, header_fmt = header_fmt)
result = open(x->read(x,String), "test-out.dat",)
println(result)
expected = """name        height age
Alice         1.60  21
Bob           1.83  40
Claire        1.75  31
David         1.50  25
Edith         1.68  30
"""
@test expected == result
rm("test-out.dat")
