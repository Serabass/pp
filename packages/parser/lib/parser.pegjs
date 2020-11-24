{
  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }
}

PDocument
 = _ parsers: Parser+ _



Parser
 = 'parser'
   _ name: Identifier
   _ '{'
   	_ body: ParserBody
   _ '}'

ParserBody
 = ParserBodyArgs _ ParserBodyFields
 
ParserBodyArgs
 = _ ( _ ParserBodyArg _ )+
 
 	ParserBodyArg
     = ('--' Identifier) _ Value EOS _ 
 
ParserBodyFields
 = ParserBodyField+
 
	ParserBodyField
     = Identifier ':' _ ParserBodyFieldExpression

		ParserBodyFieldExpression = 
        	'@' Identifier  _ StringLiteral EOS

OB = '('
CB = ')'



Identifier = [A-Za-z]+

Value
 = Identifier
 / StringLiteral












SourceCharacter 'source character'
  = [A-Za-z]
  / [А-Яа-яёЁ]
  / [0-9]
  / WhiteSpace

EOF 'end of file'
  = !.
  
__
  = (WhiteSpace / NL / Comment)*

_
  = (WhiteSpace / NL / MultiLineCommentNoLineTerminator)*

WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"

NL "end of line"
  = "\n"
  / "\r\n"
  / "\r"

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineCommentNoLineTerminator
  = "/*" (!("*/" / LineTerminator) SourceCharacter)* "*/"

MultiLineComment
  = "/*" (!"*/" SourceCharacter)* "*/"

SingleLineComment
  = "//" (!LineTerminator SourceCharacter)*

LineTerminator
  = [\n\r\u2028\u2029]

Integer = [0-9]+ {
	return parseInt(text(), 10)
}















StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", value: chars.join("") };
    }
  / "'" chars:SingleStringCharacter* "'" {
      return { type: "Literal", value: chars.join("") };
    }




DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation



SingleStringCharacter
  = !("'" / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation


LineContinuation
  = "\\" LineTerminatorSequence { return ""; }


EscapeSequence
  = CharacterEscapeSequence
  / "0" !DecimalDigit { return "\0"; }
  / HexEscapeSequence
  / UnicodeEscapeSequence


LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"


CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter


DecimalDigit
  = [0-9]

UnicodeEscapeSequence
  = "u" digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }


HexEscapeSequence
  = "x" digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }


SingleEscapeCharacter
  = "'"
  / '"'
  / "\\"
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; }

NonEscapeCharacter
  = !(EscapeCharacter / LineTerminator) SourceCharacter { return text(); }

HexDigit
  = [0-9a-f]i

EscapeCharacter
  = SingleEscapeCharacter
  / DecimalDigit
  / "x"
  / "u"


EOS = ';'