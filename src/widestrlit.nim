# Copyright 2020 Double-oxygeN
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from strutils import unindent
import macros

when defined(c) or defined(nimdoc):
  {.passC: "-std=c11".}
  when defined(windows) or defined(linux):
    {.pragma uchar, header: "<uchar.h>".}

  else:
    {.emit: """/*TYPESECTION*/
    #ifndef __USE_ISOCXX11
    typedef uint_least16_t char16_t;
    typedef uint_least32_t char32_t;
    #endif
    """.unindent().}
    template uchar {.pragma.}

  type
    Char16* {.importc: "char16_t", uchar.} = distinct uint16
    Char32* {.importc: "char32_t", uchar.} = distinct uint32

    Utf16String* {.importc: "char16_t *", uchar.} = distinct ptr UncheckedArray[Char16]
    Utf32String* {.importc: "char32_t *", uchar.} = distinct ptr UncheckedArray[Char32]


macro utf16*(strLit: string{lit}): untyped =
  let
    sym = genSym(nskConst, "str")
    symStrLit = sym.toStrLit()
  result = quote do:
    (; {.emit: ["const char16_t *", `symStrLit`, " = u\"", `strLit`, "\";"].}; let p {.importc: `symStrLit`, nodecl.}: Utf16String; p)


macro utf32*(strLit: string{lit}): untyped =
  let
    sym = genSym(nskConst, "str")
    symStrLit = sym.toStrLit()
  result = quote do:
    (; {.emit: ["const char32_t *", `symStrLit`, " = U\"", `strLit`, "\";"].}; let p {.importc: `symStrLit`, nodecl.}: Utf32String; p)


when isMainModule:
  expandMacros:
    let
      p0 = utf16"Hello!"
      p1 = utf16"こんにちは!"
      p2 = utf32"Hello!"
      p3 = utf32"😀"

    echo repr(p0)
    echo repr(p1)
    echo repr(p2)
    echo repr(p3)
