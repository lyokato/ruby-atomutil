require File.dirname(__FILE__) + '/spec_helper.rb'

require 'base64'

describe Atom::Entry, "setter/getter and building xml" do

  it "should escape body collectly" do
    entry = Atom::Entry.new
    entry.content = "&lt;br&gt;"
    entry.to_s.should == "<?xml version='1.0' encoding='UTF-8'?><entry xmlns='http://www.w3.org/2005/Atom'><content type='text'>&amp;lt;br&amp;gt;</content></entry>"
  end
end

describe Atom::Content, "setter/getter and building xml" do

  it "should set and get type" do
    content = Atom::Content.new
    content.type = "image/jpeg"
    content.type.should == "image/jpeg"
    content.type = "application/gzip"
    content.type.should == "application/gzip"
  end

  it "should construct with body collectly" do
    content = Atom::Content.new :body => 'This is a test'
    content.body.should == 'This is a test'
    content.type.should == 'text'
  end

  it "should set body and type collectly" do
    content = Atom::Content.new :body => 'This is a test', :type => 'text/bar'
    content.body.should == 'This is a test'
    content.type.should == 'text/bar'
  end

  it "should handle text body collectly" do
    content = Atom::Content.new
    content.body = 'This is a test'
    content.body.should == 'This is a test'
    content.type = 'foo/bar'
    content.type.should == 'foo/bar'
  end

  it "should handle UTF-8 text body collectly" do
    content = Atom::Content.new
    content.body = 'こんにちは'
    content.body.should == 'こんにちは'
    content.type = 'foo/bar'
    content.type.should == 'foo/bar'
  end

  it "should handle xhtml body collectly" do
    content = Atom::Content.new
    content.body = '<p>This is a test with XHTML</p>'
    content.body.should == '<p>This is a test with XHTML</p>'
    content.type.should == 'xhtml'
  end

  it "should handle invalid xhtml body collectly" do
    content = Atom::Content.new
    content.body = '<p>This is a test with invalid XHTML'
    content.body.should == '<p>This is a test with invalid XHTML'
    content.type.should == 'html'
  end

  it "should handle image data collectly" do
    img_b64 = <<EOF;
/9j/4AAQSkZJRgABAQAAkACQAAD/4QCARXhpZgAATU0AKgAAAAgABQESAAMA
AAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdp
AAQAAAABAAAAWgAAAAAAAACQAAAAAQAAAJAAAAABAAKgAgAEAAAAAQAAAGSg
AwAEAAAAAQAAAGQAAAAA/+EJIWh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEu
MC8APD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6
TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRh
LyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPiA8cmRmOlJERiB4bWxuczpy
ZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1u
cyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIi8+IDwvcmRmOlJE
Rj4gPC94OnhtcG1ldGE+ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgPD94cGFj
a2V0IGVuZD0idyI/PgD/7QA4UGhvdG9zaG9wIDMuMAA4QklNBAQAAAAAAAA4
QklNBCUAAAAAABDUHYzZjwCyBOmACZjs+EJ+/+IM5ElDQ19QUk9GSUxFAAEB
AAAM1GFwcGwCEAAAbW50clJHQiBYWVogB+IAAQAKAAAAIwAVYWNzcEFQUEwA
AAAAQVBQTAAAAAAAAAAAAAAAAAAAAAAAAPbWAAEAAAAA0y1hcHBsAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARZGVz
YwAAAVAAAABiZHNjbQAAAbQAAAG8Y3BydAAAA3AAAAAjd3RwdAAAA5QAAAAU
clhZWgAAA6gAAAAUZ1hZWgAAA7wAAAAUYlhZWgAAA9AAAAAUclRSQwAAA+QA
AAgMYWFyZwAAC/AAAAAgdmNndAAADBAAAAAwbmRpbgAADEAAAAA+Y2hhZAAA
DIAAAAAsbW1vZAAADKwAAAAoYlRSQwAAA+QAAAgMZ1RSQwAAA+QAAAgMYWFi
ZwAAC/AAAAAgYWFnZwAAC/AAAAAgZGVzYwAAAAAAAAAIRGlzcGxheQAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAG1sdWMAAAAAAAAAIwAA
AAxockhSAAAACAAAAbRrb0tSAAAACAAAAbRuYk5PAAAACAAAAbRpZAAAAAAA
CAAAAbRodUhVAAAACAAAAbRjc0NaAAAACAAAAbRkYURLAAAACAAAAbR1a1VB
AAAACAAAAbRhcgAAAAAACAAAAbR6aFRXAAAACAAAAbRyb1JPAAAACAAAAbRu
bE5MAAAACAAAAbRoZUlMAAAACAAAAbRlc0VTAAAACAAAAbRmaUZJAAAACAAA
AbRpdElUAAAACAAAAbR2aVZOAAAACAAAAbRza1NLAAAACAAAAbR6aENOAAAA
CAAAAbRydVJVAAAACAAAAbRtcwAAAAAACAAAAbRmckZSAAAACAAAAbRoaUlO
AAAACAAAAbR0aFRIAAAACAAAAbRjYUVTAAAACAAAAbRlc1hMAAAACAAAAbRk
ZURFAAAACAAAAbRlblVTAAAACAAAAbRwdEJSAAAACAAAAbRwbFBMAAAACAAA
AbRlbEdSAAAACAAAAbRzdlNFAAAACAAAAbR0clRSAAAACAAAAbRqYUpQAAAA
CAAAAbRwdFBUAAAACAAAAbQAaQBNAGEAY3RleHQAAAAAQ29weXJpZ2h0IEFw
cGxlIEluYy4sIDIwMTgAAFhZWiAAAAAAAADwzwABAAAAARkRWFlaIAAAAAAA
AIXsAAA+t////7ZYWVogAAAAAAAASbUAALIwAAALNlhZWiAAAAAAAAAnNAAA
DxkAAMhBY3VydgAAAAAAAAQAAAAABQAKAA8AFAAZAB4AIwAoAC0AMgA2ADsA
QABFAEoATwBUAFkAXgBjAGgAbQByAHcAfACBAIYAiwCQAJUAmgCfAKMAqACt
ALIAtwC8AMEAxgDLANAA1QDbAOAA5QDrAPAA9gD7AQEBBwENARMBGQEfASUB
KwEyATgBPgFFAUwBUgFZAWABZwFuAXUBfAGDAYsBkgGaAaEBqQGxAbkBwQHJ
AdEB2QHhAekB8gH6AgMCDAIUAh0CJgIvAjgCQQJLAlQCXQJnAnECegKEAo4C
mAKiAqwCtgLBAssC1QLgAusC9QMAAwsDFgMhAy0DOANDA08DWgNmA3IDfgOK
A5YDogOuA7oDxwPTA+AD7AP5BAYEEwQgBC0EOwRIBFUEYwRxBH4EjASaBKgE
tgTEBNME4QTwBP4FDQUcBSsFOgVJBVgFZwV3BYYFlgWmBbUFxQXVBeUF9gYG
BhYGJwY3BkgGWQZqBnsGjAadBq8GwAbRBuMG9QcHBxkHKwc9B08HYQd0B4YH
mQesB78H0gflB/gICwgfCDIIRghaCG4IggiWCKoIvgjSCOcI+wkQCSUJOglP
CWQJeQmPCaQJugnPCeUJ+woRCicKPQpUCmoKgQqYCq4KxQrcCvMLCwsiCzkL
UQtpC4ALmAuwC8gL4Qv5DBIMKgxDDFwMdQyODKcMwAzZDPMNDQ0mDUANWg10
DY4NqQ3DDd4N+A4TDi4OSQ5kDn8Omw62DtIO7g8JDyUPQQ9eD3oPlg+zD88P
7BAJECYQQxBhEH4QmxC5ENcQ9RETETERTxFtEYwRqhHJEegSBxImEkUSZBKE
EqMSwxLjEwMTIxNDE2MTgxOkE8UT5RQGFCcUSRRqFIsUrRTOFPAVEhU0FVYV
eBWbFb0V4BYDFiYWSRZsFo8WshbWFvoXHRdBF2UXiReuF9IX9xgbGEAYZRiK
GK8Y1Rj6GSAZRRlrGZEZtxndGgQaKhpRGncanhrFGuwbFBs7G2MbihuyG9oc
AhwqHFIcexyjHMwc9R0eHUcdcB2ZHcMd7B4WHkAeah6UHr4e6R8THz4faR+U
H78f6iAVIEEgbCCYIMQg8CEcIUghdSGhIc4h+yInIlUigiKvIt0jCiM4I2Yj
lCPCI/AkHyRNJHwkqyTaJQklOCVoJZclxyX3JicmVyaHJrcm6CcYJ0kneier
J9woDSg/KHEooijUKQYpOClrKZ0p0CoCKjUqaCqbKs8rAis2K2krnSvRLAUs
OSxuLKIs1y0MLUEtdi2rLeEuFi5MLoIuty7uLyQvWi+RL8cv/jA1MGwwpDDb
MRIxSjGCMbox8jIqMmMymzLUMw0zRjN/M7gz8TQrNGU0njTYNRM1TTWHNcI1
/TY3NnI2rjbpNyQ3YDecN9c4FDhQOIw4yDkFOUI5fzm8Ofk6Njp0OrI67zst
O2s7qjvoPCc8ZTykPOM9Ij1hPaE94D4gPmA+oD7gPyE/YT+iP+JAI0BkQKZA
50EpQWpBrEHuQjBCckK1QvdDOkN9Q8BEA0RHRIpEzkUSRVVFmkXeRiJGZ0ar
RvBHNUd7R8BIBUhLSJFI10kdSWNJqUnwSjdKfUrESwxLU0uaS+JMKkxyTLpN
Ak1KTZNN3E4lTm5Ot08AT0lPk0/dUCdQcVC7UQZRUFGbUeZSMVJ8UsdTE1Nf
U6pT9lRCVI9U21UoVXVVwlYPVlxWqVb3V0RXklfgWC9YfVjLWRpZaVm4Wgda
VlqmWvVbRVuVW+VcNVyGXNZdJ114XcleGl5sXr1fD19hX7NgBWBXYKpg/GFP
YaJh9WJJYpxi8GNDY5dj62RAZJRk6WU9ZZJl52Y9ZpJm6Gc9Z5Nn6Wg/aJZo
7GlDaZpp8WpIap9q92tPa6dr/2xXbK9tCG1gbbluEm5rbsRvHm94b9FwK3CG
cOBxOnGVcfByS3KmcwFzXXO4dBR0cHTMdSh1hXXhdj52m3b4d1Z3s3gReG54
zHkqeYl553pGeqV7BHtje8J8IXyBfOF9QX2hfgF+Yn7CfyN/hH/lgEeAqIEK
gWuBzYIwgpKC9INXg7qEHYSAhOOFR4Wrhg6GcobXhzuHn4gEiGmIzokziZmJ
/opkisqLMIuWi/yMY4zKjTGNmI3/jmaOzo82j56QBpBukNaRP5GokhGSepLj
k02TtpQglIqU9JVflcmWNJaflwqXdZfgmEyYuJkkmZCZ/JpomtWbQpuvnByc
iZz3nWSd0p5Anq6fHZ+Ln/qgaaDYoUehtqImopajBqN2o+akVqTHpTilqaYa
poum/adup+CoUqjEqTepqaocqo+rAqt1q+msXKzQrUStuK4trqGvFq+LsACw
dbDqsWCx1rJLssKzOLOutCW0nLUTtYq2AbZ5tvC3aLfguFm40blKucK6O7q1
uy67p7whvJu9Fb2Pvgq+hL7/v3q/9cBwwOzBZ8Hjwl/C28NYw9TEUcTOxUvF
yMZGxsPHQce/yD3IvMk6ybnKOMq3yzbLtsw1zLXNNc21zjbOts83z7jQOdC6
0TzRvtI/0sHTRNPG1EnUy9VO1dHWVdbY11zX4Nhk2OjZbNnx2nba+9uA3AXc
it0Q3ZbeHN6i3ynfr+A24L3hROHM4lPi2+Nj4+vkc+T85YTmDeaW5x/nqegy
6LzpRunQ6lvq5etw6/vshu0R7ZzuKO6070DvzPBY8OXxcvH/8ozzGfOn9DT0
wvVQ9d72bfb794r4Gfio+Tj5x/pX+uf7d/wH/Jj9Kf26/kv+3P9t//9wYXJh
AAAAAAADAAAAAmZmAADypwAADVkAABPQAAAKW3ZjZ3QAAAAAAAAAAQABAAAA
AAAAAAEAAAABAAAAAAAAAAEAAAABAAAAAAAAAAEAAG5kaW4AAAAAAAAANgAA
rgAAAFIAAABBgAAAskAAACYAAAAOAAAAT0AAAFRAAAIzMwACMzMAAjMzAAAA
AAAAAABzZjMyAAAAAAABDqsAAAch///ybwAACW8AAPxH///7UP///ZwAAAPU
AAC+6G1tb2QAAAAAAAAGEAAArhNoYy5F0v6AgAAAAAAAAAAAAAAAAAAAAAD/
wAARCABkAGQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQF
BgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJx
FDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdI
SUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKj
pKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx
8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QA
tREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHB
CSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldY
WVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmq
srO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6
/9sAQwACAgICAgIDAgIDBAMDAwQFBAQEBAUHBQUFBQUHCAcHBwcHBwgICAgI
CAgICgoKCgoKCwsLCwsNDQ0NDQ0NDQ0N/9sAQwECAgIDAwMGAwMGDQkHCQ0N
DQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0N
DQ0N/90ABAAH/9oADAMBAAIRAxEAPwD+f+iiigAooooAKKKKACiiigAooooA
KKKKACiiigD/0P5/6KKKACiium8IeD/EHjrXrfw34atWur24PAHCRoPvSSN0
VF7k/QZJAIa0KFStUjSoxcpN2SWrbfRHM13Phz4Z/EDxcizeHPD+oX0LdJ0g
YQH/ALasAn/j1fpL8Lf2YvA3gOGG/wBehj8Qa0AGae5TdbQtjpDC2V4PR3Bb
uNvSvpVVVFCqAABgAcAAVDn2P3HIPBSvWpqrm1bkv9mNm/nLZP0T9T8hP+GZ
fjh5fm/8Iy+3rj7ZZ7v++fPz+lcB4j+GfxA8Io03iPw/qFjCvWd4GMA/7aqC
n/j1ft3SMqupVgCCMEHkEGp52fR4nwQyuULYfEVIy7vlkvuSj+Z+BlFfq78U
v2YvA3jyGa/0GGPw/rRBZZrZNttM3pNCuF5PV0Abud3SvzI8X+D/ABB4F164
8N+JbVrW9tzyDykiH7skbdGRuxH0OCCBopJn4xxZwNmOQTTxK5qb2mtvR9n5
P5NnM0UUUz40KKKKAP/R/n/ooooAlhhmuZo7e3RpJZWCIijLMzHAAA6knpX7
A/Ar4R2Hwq8JRQzRI2u36LLqdwMMd/UQq3/POLOPdst3GPgn9lfwhF4p+LFn
d3Sb7bQoX1JgehljKpD+IkcOP92v1krOb6H9D+C/DVP2U86rK8ruMPJL4mvW
9vk+4VpaRo+qa9fx6Zo1rLeXUpwscS7j7k9go7scADkms2vuf9nzw5Y6b4JT
X0QG81eSUvIR8wihkaJUHtlSx9SeegqYRu7H65xNnqynBPE8t5NpJdLu+/lZ
M8J/4Z6+Iv2L7V5dn5uzd9m+0jzc4+7nHl57ffx7968g1fR9U0G/k0zWbWWz
uojho5V2n2I7FT2YZBHINfqdXg37Qnh2x1LwS+vugW80mSIpIB8ximkWNkJ9
MsGHoRx1NaSpq10fB8PeIOKxGNhhsbFcs3ZNJppvbq7q/wDw58MV4j8dfhHY
/FTwlLDDEi67p6NLplwcKd/Uwsf7kuMezYbtz7dRWKZ+n5nluHx+Fng8VG8J
qzX6+q3T6M/BCaGa2mkt7hGjliYo6OMMrKcEEHkEHgioq+kP2qPCEXhb4sXl
3aJsttdhTU1A6CWQsk34mRC5/wB6vm+uhM/hzOssnl2PrYGpvCTXrbZ/NahR
RRQeYf/S/n/ooooA+8f2H7aN7zxheEDzIotOiU99shuCf1QV+gdfm5+xVrcV
p4y17QJGCtqOnxzoD/E1pJjA99spP0Br9I6xnuf174T1YS4ZoRjunNP152/y
aCvsn9nvx1p1xoq+B72VYb60kke0Vjjz4ZCZGVcnl0YsSOu05GcNj42rX0rR
9d1OTfodjd3ckTA5tIXkZWHI5QEg+lEZWdz6riPKKGZYKWHry5eqfZrr+Nvm
fqTXzR+0J460630VvA9lKs19dyRvdqpz5EUZEiq2Dw7sFIHXaCTjK58r+y/t
B/2Z9n/4n/2fbnG9/Ox1xnPm/hnpxivIdV0fXdMk365Y3dpJKxObuF42Zjye
XAJPrWkpu1rHwXDXBmHo42OIq4iE+R3Si76rZv03t+JkUUUVifrR+fn7cFtG
l54PvAP3ksWoxMf9mM25H6ua+Dq+0f21dbiu/GWhaBG246dp8k7gfwtdyYwf
fbED9CK+Lq2jsfxr4mVYVOJsVKnteK+ahFP8Uwoooqj4U//T/n/ooooA7j4b
+M7n4f8AjfSPFtuGcWFwDNGpwZLdwUlQdstGxAz0ODX7Y6NfWviGys9Q0SQX
lvqEcclq8OW81ZQCm0Dkk5HHXPFfgtX29+yN+0Za/DzxTonhLx7c+X4bGpW0
sF6+SNPPnKz7+/kMcsSPuHJ6E4mUbn634X8b08oqVMDjHalPVPop26+UtE30
aXS7P358BfAfw5oNtDfeKYk1XUyAzRSfNawsQcqE6SEZwS+RkZAHU+9RRRQR
LDAixRoMKiAKoHsBwKitLu01C1hv7CaO5trmNZoZoXEkckcgDK6MpIZWBBBB
wRyKsVqklsVmWbYvH1XWxU3J/gvRbIKZLFFPE0M6LLG4wyOAyke4PBp9FM89
O2qPAvHvwH8Oa9bTX3haJNK1MKWWKP5bWZgBhSnSMnGAUwMnJB6j4R1m+tfD
1le6jrcgs7fT45JLp5vl8pYgS+4HkEYPHXPFfrHd3dpp9rNf380dtbW0bTTT
TOI4444wWZ3ZiAqqASSTgDk1/Mj+1z+0Za/EPxTrfhLwFc+Z4bOpXEs96hIG
oHzmZNnfyFOGBP3zg9AM5Tguh97k/iHLK8BW+vT52kvZp6tvXS+/KtG30W26
R8s/Ejxnc/EDxvq/i24DIL+4JhjY5MdugCRIe2VjUA46nJrh6KKZ/PmKxNTE
Vp4is7yk22+7buwooooMD//U/n/ooooAKKKKAPrL9n79s741/s8bNM8N6gmr
+HN+59C1XdNaLn7xgYMJLdup/dsELHLI1fqv4A/4Kt/BTXLaOL4gaFrPhe9I
HmNAialZg98SIY5vw8n8a/n2oppnoYbM8RRXLGWnZn9O3/Dxj9j/AOz+d/wn
Eu/GfK/sbVN/0z9k2/8Aj1eJeP8A/gq38FNDtpIvh/oWs+KL0A+W06pptmT2
zI5km/Dyfxr+faijmZ1Tz7EyVlZfL/M+sv2gf2zvjX+0Pv0zxJqCaR4c37k0
LSt0No2PumdixkuG6H94xQMMqi18m0UUjyatWdSXNUd2FFFFBmFFFFAH/9X+
f+iiigAooooAKKKKACiiigAooooAKKKKACiiigD/2Q==
EOF

    img = Base64.decode64(img_b64)
    content = Atom::Content.new
    content.type = 'image/jpeg'
    content.body = img
    content.type.should == 'image/jpeg'
    content.body.should == img
  end

end

