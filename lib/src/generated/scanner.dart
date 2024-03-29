// This code was auto-generated, is not intended to be edited, and is subject to
// significant change. Please see the README file for more information.

library engine.scanner;

import 'dart:collection';
import 'java_core.dart';
import 'source.dart';
import 'error.dart';
import 'instrumentation.dart';

/**
 * Instances of the abstract class {@code KeywordState} represent a state in a state machine used to
 * scan keywords.
 * @coverage dart.engine.parser
 */
class KeywordState {
  /**
   * An empty transition table used by leaf states.
   */
  static List<KeywordState> _EMPTY_TABLE = new List<KeywordState>(26);
  /**
   * The initial state in the state machine.
   */
  static KeywordState KEYWORD_STATE = createKeywordStateTable();
  /**
   * Create the next state in the state machine where we have already recognized the subset of
   * strings in the given array of strings starting at the given offset and having the given length.
   * All of these strings have a common prefix and the next character is at the given start index.
   * @param start the index of the character in the strings used to transition to a new state
   * @param strings an array containing all of the strings that will be recognized by the state
   * machine
   * @param offset the offset of the first string in the array that has the prefix that is assumed
   * to have been recognized by the time we reach the state being built
   * @param length the number of strings in the array that pass through the state being built
   * @return the state that was created
   */
  static KeywordState computeKeywordStateTable(int start, List<String> strings, int offset, int length12) {
    List<KeywordState> result = new List<KeywordState>(26);
    assert(length12 != 0);
    int chunk = 0x0;
    int chunkStart = -1;
    bool isLeaf = false;
    for (int i = offset; i < offset + length12; i++) {
      if (strings[i].length == start) {
        isLeaf = true;
      }
      if (strings[i].length > start) {
        int c = strings[i].codeUnitAt(start);
        if (chunk != c) {
          if (chunkStart != -1) {
            result[chunk - 0x61] = computeKeywordStateTable(start + 1, strings, chunkStart, i - chunkStart);
          }
          chunkStart = i;
          chunk = c;
        }
      }
    }
    if (chunkStart != -1) {
      assert(result[chunk - 0x61] == null);
      result[chunk - 0x61] = computeKeywordStateTable(start + 1, strings, chunkStart, offset + length12 - chunkStart);
    } else {
      assert(length12 == 1);
      return new KeywordState(_EMPTY_TABLE, strings[offset]);
    }
    if (isLeaf) {
      return new KeywordState(result, strings[offset]);
    } else {
      return new KeywordState(result, null);
    }
  }
  /**
   * Create the initial state in the state machine.
   * @return the state that was created
   */
  static KeywordState createKeywordStateTable() {
    List<Keyword> values2 = Keyword.values;
    List<String> strings = new List<String>(values2.length);
    for (int i = 0; i < values2.length; i++) {
      strings[i] = values2[i].syntax;
    }
    strings.sort();
    return computeKeywordStateTable(0, strings, 0, strings.length);
  }
  /**
   * A table mapping characters to the states to which those characters will transition. (The index
   * into the array is the offset from the character {@code 'a'} to the transitioning character.)
   */
  List<KeywordState> _table;
  /**
   * The keyword that is recognized by this state, or {@code null} if this state is not a terminal
   * state.
   */
  Keyword _keyword2;
  /**
   * Initialize a newly created state to have the given transitions and to recognize the keyword
   * with the given syntax.
   * @param table a table mapping characters to the states to which those characters will transition
   * @param syntax the syntax of the keyword that is recognized by the state
   */
  KeywordState(List<KeywordState> table, String syntax) {
    this._table = table;
    this._keyword2 = (syntax == null) ? null : Keyword.keywords[syntax];
  }
  /**
   * Return the keyword that was recognized by this state, or {@code null} if this state does not
   * recognized a keyword.
   * @return the keyword that was matched by reaching this state
   */
  Keyword keyword() => _keyword2;
  /**
   * Return the state that follows this state on a transition of the given character, or{@code null} if there is no valid state reachable from this state with such a transition.
   * @param c the character used to transition from this state to another state
   * @return the state that follows this state on a transition of the given character
   */
  KeywordState next(int c) => _table[c - 0x61];
}
/**
 * The enumeration {@code ScannerErrorCode} defines the error codes used for errors detected by the
 * scanner.
 * @coverage dart.engine.parser
 */
class ScannerErrorCode implements ErrorCode {
  static final ScannerErrorCode ILLEGAL_CHARACTER = new ScannerErrorCode('ILLEGAL_CHARACTER', 0, "Illegal character %x");
  static final ScannerErrorCode MISSING_DIGIT = new ScannerErrorCode('MISSING_DIGIT', 1, "Decimal digit expected");
  static final ScannerErrorCode MISSING_HEX_DIGIT = new ScannerErrorCode('MISSING_HEX_DIGIT', 2, "Hexidecimal digit expected");
  static final ScannerErrorCode MISSING_QUOTE = new ScannerErrorCode('MISSING_QUOTE', 3, "Expected quote (' or \")");
  static final ScannerErrorCode UNTERMINATED_MULTI_LINE_COMMENT = new ScannerErrorCode('UNTERMINATED_MULTI_LINE_COMMENT', 4, "Unterminated multi-line comment");
  static final ScannerErrorCode UNTERMINATED_STRING_LITERAL = new ScannerErrorCode('UNTERMINATED_STRING_LITERAL', 5, "Unterminated string literal");
  static final List<ScannerErrorCode> values = [ILLEGAL_CHARACTER, MISSING_DIGIT, MISSING_HEX_DIGIT, MISSING_QUOTE, UNTERMINATED_MULTI_LINE_COMMENT, UNTERMINATED_STRING_LITERAL];
  final String __name;
  final int __ordinal;
  int get ordinal => __ordinal;
  /**
   * The message template used to create the message to be displayed for this error.
   */
  String _message;
  /**
   * Initialize a newly created error code to have the given message.
   * @param message the message template used to create the message to be displayed for this error
   */
  ScannerErrorCode(this.__name, this.__ordinal, String message) {
    this._message = message;
  }
  ErrorSeverity get errorSeverity => ErrorSeverity.ERROR;
  String get message => _message;
  ErrorType get type => ErrorType.SYNTACTIC_ERROR;
  bool needsRecompilation() => true;
  String toString() => __name;
}
/**
 * Instances of the class {@code TokenWithComment} represent a string token that is preceded by
 * comments.
 * @coverage dart.engine.parser
 */
class StringTokenWithComment extends StringToken {
  /**
   * The first comment in the list of comments that precede this token.
   */
  Token _precedingComment;
  /**
   * Initialize a newly created token to have the given type and offset and to be preceded by the
   * comments reachable from the given comment.
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   * @param precedingComment the first comment in the list of comments that precede this token
   */
  StringTokenWithComment(TokenType type, String value, int offset, Token precedingComment) : super(type, value, offset) {
    this._precedingComment = precedingComment;
  }
  Token get precedingComments => _precedingComment;
}
/**
 * The enumeration {@code Keyword} defines the keywords in the Dart programming language.
 * @coverage dart.engine.parser
 */
class Keyword {
  static final Keyword ASSERT = new Keyword.con1('ASSERT', 0, "assert");
  static final Keyword BREAK = new Keyword.con1('BREAK', 1, "break");
  static final Keyword CASE = new Keyword.con1('CASE', 2, "case");
  static final Keyword CATCH = new Keyword.con1('CATCH', 3, "catch");
  static final Keyword CLASS = new Keyword.con1('CLASS', 4, "class");
  static final Keyword CONST = new Keyword.con1('CONST', 5, "const");
  static final Keyword CONTINUE = new Keyword.con1('CONTINUE', 6, "continue");
  static final Keyword DEFAULT = new Keyword.con1('DEFAULT', 7, "default");
  static final Keyword DO = new Keyword.con1('DO', 8, "do");
  static final Keyword ELSE = new Keyword.con1('ELSE', 9, "else");
  static final Keyword EXTENDS = new Keyword.con1('EXTENDS', 10, "extends");
  static final Keyword FALSE = new Keyword.con1('FALSE', 11, "false");
  static final Keyword FINAL = new Keyword.con1('FINAL', 12, "final");
  static final Keyword FINALLY = new Keyword.con1('FINALLY', 13, "finally");
  static final Keyword FOR = new Keyword.con1('FOR', 14, "for");
  static final Keyword IF = new Keyword.con1('IF', 15, "if");
  static final Keyword IN = new Keyword.con1('IN', 16, "in");
  static final Keyword IS = new Keyword.con1('IS', 17, "is");
  static final Keyword NEW = new Keyword.con1('NEW', 18, "new");
  static final Keyword NULL = new Keyword.con1('NULL', 19, "null");
  static final Keyword RETURN = new Keyword.con1('RETURN', 20, "return");
  static final Keyword SUPER = new Keyword.con1('SUPER', 21, "super");
  static final Keyword SWITCH = new Keyword.con1('SWITCH', 22, "switch");
  static final Keyword THIS = new Keyword.con1('THIS', 23, "this");
  static final Keyword THROW = new Keyword.con1('THROW', 24, "throw");
  static final Keyword TRUE = new Keyword.con1('TRUE', 25, "true");
  static final Keyword TRY = new Keyword.con1('TRY', 26, "try");
  static final Keyword VAR = new Keyword.con1('VAR', 27, "var");
  static final Keyword VOID = new Keyword.con1('VOID', 28, "void");
  static final Keyword WHILE = new Keyword.con1('WHILE', 29, "while");
  static final Keyword WITH = new Keyword.con1('WITH', 30, "with");
  static final Keyword ABSTRACT = new Keyword.con2('ABSTRACT', 31, "abstract", true);
  static final Keyword AS = new Keyword.con2('AS', 32, "as", true);
  static final Keyword DYNAMIC = new Keyword.con2('DYNAMIC', 33, "dynamic", true);
  static final Keyword EXPORT = new Keyword.con2('EXPORT', 34, "export", true);
  static final Keyword EXTERNAL = new Keyword.con2('EXTERNAL', 35, "external", true);
  static final Keyword FACTORY = new Keyword.con2('FACTORY', 36, "factory", true);
  static final Keyword GET = new Keyword.con2('GET', 37, "get", true);
  static final Keyword IMPLEMENTS = new Keyword.con2('IMPLEMENTS', 38, "implements", true);
  static final Keyword IMPORT = new Keyword.con2('IMPORT', 39, "import", true);
  static final Keyword LIBRARY = new Keyword.con2('LIBRARY', 40, "library", true);
  static final Keyword OPERATOR = new Keyword.con2('OPERATOR', 41, "operator", true);
  static final Keyword PART = new Keyword.con2('PART', 42, "part", true);
  static final Keyword SET = new Keyword.con2('SET', 43, "set", true);
  static final Keyword STATIC = new Keyword.con2('STATIC', 44, "static", true);
  static final Keyword TYPEDEF = new Keyword.con2('TYPEDEF', 45, "typedef", true);
  static final List<Keyword> values = [ASSERT, BREAK, CASE, CATCH, CLASS, CONST, CONTINUE, DEFAULT, DO, ELSE, EXTENDS, FALSE, FINAL, FINALLY, FOR, IF, IN, IS, NEW, NULL, RETURN, SUPER, SWITCH, THIS, THROW, TRUE, TRY, VAR, VOID, WHILE, WITH, ABSTRACT, AS, DYNAMIC, EXPORT, EXTERNAL, FACTORY, GET, IMPLEMENTS, IMPORT, LIBRARY, OPERATOR, PART, SET, STATIC, TYPEDEF];
  String __name;
  int __ordinal = 0;
  int get ordinal => __ordinal;
  /**
   * The lexeme for the keyword.
   */
  String _syntax;
  /**
   * A flag indicating whether the keyword is a pseudo-keyword. Pseudo keywords can be used as
   * identifiers.
   */
  bool _isPseudoKeyword2 = false;
  /**
   * A table mapping the lexemes of keywords to the corresponding keyword.
   */
  static Map<String, Keyword> keywords = createKeywordMap();
  /**
   * Create a table mapping the lexemes of keywords to the corresponding keyword.
   * @return the table that was created
   */
  static Map<String, Keyword> createKeywordMap() {
    LinkedHashMap<String, Keyword> result = new LinkedHashMap<String, Keyword>();
    for (Keyword keyword in values) {
      result[keyword._syntax] = keyword;
    }
    return result;
  }
  /**
   * Initialize a newly created keyword to have the given syntax. The keyword is not a
   * pseudo-keyword.
   * @param syntax the lexeme for the keyword
   */
  Keyword.con1(String ___name, int ___ordinal, String syntax) {
    _jtd_constructor_278_impl(___name, ___ordinal, syntax);
  }
  _jtd_constructor_278_impl(String ___name, int ___ordinal, String syntax) {
    _jtd_constructor_279_impl(___name, ___ordinal, syntax, false);
  }
  /**
   * Initialize a newly created keyword to have the given syntax. The keyword is a pseudo-keyword if
   * the given flag is {@code true}.
   * @param syntax the lexeme for the keyword
   * @param isPseudoKeyword {@code true} if this keyword is a pseudo-keyword
   */
  Keyword.con2(String ___name, int ___ordinal, String syntax2, bool isPseudoKeyword) {
    _jtd_constructor_279_impl(___name, ___ordinal, syntax2, isPseudoKeyword);
  }
  _jtd_constructor_279_impl(String ___name, int ___ordinal, String syntax2, bool isPseudoKeyword) {
    __name = ___name;
    __ordinal = ___ordinal;
    this._syntax = syntax2;
    this._isPseudoKeyword2 = isPseudoKeyword;
  }
  /**
   * Return the lexeme for the keyword.
   * @return the lexeme for the keyword
   */
  String get syntax => _syntax;
  /**
   * Return {@code true} if this keyword is a pseudo-keyword. Pseudo keywords can be used as
   * identifiers.
   * @return {@code true} if this keyword is a pseudo-keyword
   */
  bool isPseudoKeyword() => _isPseudoKeyword2;
  String toString() => __name;
}
/**
 * The abstract class {@code AbstractScanner} implements a scanner for Dart code. Subclasses are
 * required to implement the interface used to access the characters being scanned.
 * <p>
 * The lexical structure of Dart is ambiguous without knowledge of the context in which a token is
 * being scanned. For example, without context we cannot determine whether source of the form "<<"
 * should be scanned as a single left-shift operator or as two left angle brackets. This scanner
 * does not have any context, so it always resolves such conflicts by scanning the longest possible
 * token.
 * @coverage dart.engine.parser
 */
abstract class AbstractScanner {
  /**
   * The source being scanned.
   */
  Source _source;
  /**
   * The error listener that will be informed of any errors that are found during the scan.
   */
  AnalysisErrorListener _errorListener;
  /**
   * The token pointing to the head of the linked list of tokens.
   */
  Token _tokens;
  /**
   * The last token that was scanned.
   */
  Token _tail;
  /**
   * The first token in the list of comment tokens found since the last non-comment token.
   */
  Token _firstComment;
  /**
   * The last token in the list of comment tokens found since the last non-comment token.
   */
  Token _lastComment;
  /**
   * The index of the first character of the current token.
   */
  int _tokenStart = 0;
  /**
   * A list containing the offsets of the first character of each line in the source code.
   */
  List<int> _lineStarts = new List<int>();
  /**
   * A list, treated something like a stack, of tokens representing the beginning of a matched pair.
   * It is used to pair the end tokens with the begin tokens.
   */
  List<BeginToken> _groupingStack = new List<BeginToken>();
  /**
   * A flag indicating whether any unmatched groups were found during the parse.
   */
  bool _hasUnmatchedGroups2 = false;
  /**
   * A non-breaking space, which is allowed by this scanner as a white-space character.
   */
  static int _$NBSP = 160;
  /**
   * Initialize a newly created scanner.
   * @param source the source being scanned
   * @param errorListener the error listener that will be informed of any errors that are found
   */
  AbstractScanner(Source source, AnalysisErrorListener errorListener) {
    this._source = source;
    this._errorListener = errorListener;
    _tokens = new Token(TokenType.EOF, -1);
    _tokens.setNext(_tokens);
    _tail = _tokens;
    _tokenStart = -1;
    _lineStarts.add(0);
  }
  /**
   * Return an array containing the offsets of the first character of each line in the source code.
   * @return an array containing the offsets of the first character of each line in the source code
   */
  List<int> get lineStarts => _lineStarts;
  /**
   * Return the current offset relative to the beginning of the file. Return the initial offset if
   * the scanner has not yet scanned the source code, and one (1) past the end of the source code if
   * the source code has been scanned.
   * @return the current offset of the scanner in the source
   */
  int get offset;
  /**
   * Return {@code true} if any unmatched groups were found during the parse.
   * @return {@code true} if any unmatched groups were found during the parse
   */
  bool hasUnmatchedGroups() => _hasUnmatchedGroups2;
  /**
   * Scan the source code to produce a list of tokens representing the source.
   * @return the first token in the list of tokens that were produced
   */
  Token tokenize() {
    int next = advance();
    while (next != -1) {
      next = bigSwitch(next);
    }
    appendEofToken();
    return firstToken();
  }
  /**
   * Advance the current position and return the character at the new current position.
   * @return the character at the new current position
   */
  int advance();
  /**
   * Return the substring of the source code between the start offset and the modified current
   * position. The current position is modified by adding the end delta.
   * @param start the offset to the beginning of the string, relative to the start of the file
   * @param endDelta the number of character after the current location to be included in the
   * string, or the number of characters before the current location to be excluded if the
   * offset is negative
   * @return the specified substring of the source code
   */
  String getString(int start, int endDelta);
  /**
   * Return the character at the current position without changing the current position.
   * @return the character at the current position
   */
  int peek();
  /**
   * Record the fact that we are at the beginning of a new line in the source.
   */
  void recordStartOfLine() {
    _lineStarts.add(offset);
  }
  void appendBeginToken(TokenType type) {
    BeginToken token;
    if (_firstComment == null) {
      token = new BeginToken(type, _tokenStart);
    } else {
      token = new BeginTokenWithComment(type, _tokenStart, _firstComment);
      _firstComment = null;
      _lastComment = null;
    }
    _tail = _tail.setNext(token);
    _groupingStack.add(token);
  }
  void appendCommentToken(TokenType type, String value) {
    if (_firstComment == null) {
      _firstComment = new StringToken(type, value, _tokenStart);
      _lastComment = _firstComment;
    } else {
      _lastComment = _lastComment.setNext(new StringToken(type, value, _tokenStart));
    }
  }
  void appendEndToken(TokenType type33, TokenType beginType) {
    Token token;
    if (_firstComment == null) {
      token = new Token(type33, _tokenStart);
    } else {
      token = new TokenWithComment(type33, _tokenStart, _firstComment);
      _firstComment = null;
      _lastComment = null;
    }
    _tail = _tail.setNext(token);
    int last = _groupingStack.length - 1;
    if (last >= 0) {
      BeginToken begin = _groupingStack[last];
      if (identical(begin.type, beginType)) {
        begin.endToken = token;
        _groupingStack.removeAt(last);
      }
    }
  }
  void appendEofToken() {
    Token eofToken;
    if (_firstComment == null) {
      eofToken = new Token(TokenType.EOF, offset + 1);
    } else {
      eofToken = new TokenWithComment(TokenType.EOF, offset + 1, _firstComment);
      _firstComment = null;
      _lastComment = null;
    }
    eofToken.setNext(eofToken);
    _tail = _tail.setNext(eofToken);
    if (!_groupingStack.isEmpty) {
      _hasUnmatchedGroups2 = true;
    }
  }
  void appendKeywordToken(Keyword keyword) {
    if (_firstComment == null) {
      _tail = _tail.setNext(new KeywordToken(keyword, _tokenStart));
    } else {
      _tail = _tail.setNext(new KeywordTokenWithComment(keyword, _tokenStart, _firstComment));
      _firstComment = null;
      _lastComment = null;
    }
  }
  void appendStringToken(TokenType type, String value) {
    if (_firstComment == null) {
      _tail = _tail.setNext(new StringToken(type, value, _tokenStart));
    } else {
      _tail = _tail.setNext(new StringTokenWithComment(type, value, _tokenStart, _firstComment));
      _firstComment = null;
      _lastComment = null;
    }
  }
  void appendStringToken2(TokenType type, String value, int offset) {
    if (_firstComment == null) {
      _tail = _tail.setNext(new StringToken(type, value, _tokenStart + offset));
    } else {
      _tail = _tail.setNext(new StringTokenWithComment(type, value, _tokenStart + offset, _firstComment));
      _firstComment = null;
      _lastComment = null;
    }
  }
  void appendToken(TokenType type) {
    if (_firstComment == null) {
      _tail = _tail.setNext(new Token(type, _tokenStart));
    } else {
      _tail = _tail.setNext(new TokenWithComment(type, _tokenStart, _firstComment));
      _firstComment = null;
      _lastComment = null;
    }
  }
  void appendToken2(TokenType type, int offset) {
    if (_firstComment == null) {
      _tail = _tail.setNext(new Token(type, offset));
    } else {
      _tail = _tail.setNext(new TokenWithComment(type, offset, _firstComment));
      _firstComment = null;
      _lastComment = null;
    }
  }
  void beginToken() {
    _tokenStart = offset;
  }
  int bigSwitch(int next) {
    beginToken();
    if (next == 0xD) {
      next = advance();
      if (next == 0xA) {
        next = advance();
      }
      recordStartOfLine();
      return next;
    } else if (next == 0xA) {
      recordStartOfLine();
      return advance();
    } else if (next == 0x9 || next == 0x20) {
      return advance();
    }
    if (next == 0x72) {
      int peek3 = peek();
      if (peek3 == 0x22 || peek3 == 0x27) {
        int start = offset;
        return tokenizeString(advance(), start, true);
      }
    }
    if (0x61 <= next && next <= 0x7A) {
      return tokenizeKeywordOrIdentifier(next, true);
    }
    if ((0x41 <= next && next <= 0x5A) || next == 0x5F || next == 0x24) {
      return tokenizeIdentifier(next, offset, true);
    }
    if (next == 0x3C) {
      return tokenizeLessThan(next);
    }
    if (next == 0x3E) {
      return tokenizeGreaterThan(next);
    }
    if (next == 0x3D) {
      return tokenizeEquals(next);
    }
    if (next == 0x21) {
      return tokenizeExclamation(next);
    }
    if (next == 0x2B) {
      return tokenizePlus(next);
    }
    if (next == 0x2D) {
      return tokenizeMinus(next);
    }
    if (next == 0x2A) {
      return tokenizeMultiply(next);
    }
    if (next == 0x25) {
      return tokenizePercent(next);
    }
    if (next == 0x26) {
      return tokenizeAmpersand(next);
    }
    if (next == 0x7C) {
      return tokenizeBar(next);
    }
    if (next == 0x5E) {
      return tokenizeCaret(next);
    }
    if (next == 0x5B) {
      return tokenizeOpenSquareBracket(next);
    }
    if (next == 0x7E) {
      return tokenizeTilde(next);
    }
    if (next == 0x5C) {
      appendToken(TokenType.BACKSLASH);
      return advance();
    }
    if (next == 0x23) {
      return tokenizeTag(next);
    }
    if (next == 0x28) {
      appendBeginToken(TokenType.OPEN_PAREN);
      return advance();
    }
    if (next == 0x29) {
      appendEndToken(TokenType.CLOSE_PAREN, TokenType.OPEN_PAREN);
      return advance();
    }
    if (next == 0x2C) {
      appendToken(TokenType.COMMA);
      return advance();
    }
    if (next == 0x3A) {
      appendToken(TokenType.COLON);
      return advance();
    }
    if (next == 0x3B) {
      appendToken(TokenType.SEMICOLON);
      return advance();
    }
    if (next == 0x3F) {
      appendToken(TokenType.QUESTION);
      return advance();
    }
    if (next == 0x5D) {
      appendEndToken(TokenType.CLOSE_SQUARE_BRACKET, TokenType.OPEN_SQUARE_BRACKET);
      return advance();
    }
    if (next == 0x60) {
      appendToken(TokenType.BACKPING);
      return advance();
    }
    if (next == 0x7B) {
      appendBeginToken(TokenType.OPEN_CURLY_BRACKET);
      return advance();
    }
    if (next == 0x7D) {
      appendEndToken(TokenType.CLOSE_CURLY_BRACKET, TokenType.OPEN_CURLY_BRACKET);
      return advance();
    }
    if (next == 0x2F) {
      return tokenizeSlashOrComment(next);
    }
    if (next == 0x40) {
      appendToken(TokenType.AT);
      return advance();
    }
    if (next == 0x22 || next == 0x27) {
      return tokenizeString(next, offset, false);
    }
    if (next == 0x2E) {
      return tokenizeDotOrNumber(next);
    }
    if (next == 0x30) {
      return tokenizeHexOrNumber(next);
    }
    if (0x31 <= next && next <= 0x39) {
      return tokenizeNumber(next);
    }
    if (next == -1) {
      return -1;
    }
    if (Character.isLetter(next)) {
      return tokenizeIdentifier(next, offset, true);
    }
    if (next == _$NBSP) {
      return advance();
    }
    reportError(ScannerErrorCode.ILLEGAL_CHARACTER, [next]);
    return advance();
  }
  /**
   * Return the beginning token corresponding to a closing brace that was found while scanning
   * inside a string interpolation expression. Tokens that cannot be matched with the closing brace
   * will be dropped from the stack.
   * @return the token to be paired with the closing brace
   */
  BeginToken findTokenMatchingClosingBraceInInterpolationExpression() {
    int last = _groupingStack.length - 1;
    while (last >= 0) {
      BeginToken begin = _groupingStack[last];
      if (identical(begin.type, TokenType.OPEN_CURLY_BRACKET) || identical(begin.type, TokenType.STRING_INTERPOLATION_EXPRESSION)) {
        return begin;
      }
      _hasUnmatchedGroups2 = true;
      _groupingStack.removeAt(last);
      last--;
    }
    return null;
  }
  Token firstToken() => _tokens.next;
  /**
   * Return the source being scanned.
   * @return the source being scanned
   */
  Source get source => _source;
  /**
   * Report an error at the current offset.
   * @param errorCode the error code indicating the nature of the error
   * @param arguments any arguments needed to complete the error message
   */
  void reportError(ScannerErrorCode errorCode, List<Object> arguments) {
    _errorListener.onError(new AnalysisError.con2(source, offset, 1, errorCode, [arguments]));
  }
  int select(int choice, TokenType yesType, TokenType noType) {
    int next = advance();
    if (next == choice) {
      appendToken(yesType);
      return advance();
    } else {
      appendToken(noType);
      return next;
    }
  }
  int select2(int choice, TokenType yesType, TokenType noType, int offset) {
    int next = advance();
    if (next == choice) {
      appendToken2(yesType, offset);
      return advance();
    } else {
      appendToken2(noType, offset);
      return next;
    }
  }
  int tokenizeAmpersand(int next) {
    next = advance();
    if (next == 0x26) {
      appendToken(TokenType.AMPERSAND_AMPERSAND);
      return advance();
    } else if (next == 0x3D) {
      appendToken(TokenType.AMPERSAND_EQ);
      return advance();
    } else {
      appendToken(TokenType.AMPERSAND);
      return next;
    }
  }
  int tokenizeBar(int next) {
    next = advance();
    if (next == 0x7C) {
      appendToken(TokenType.BAR_BAR);
      return advance();
    } else if (next == 0x3D) {
      appendToken(TokenType.BAR_EQ);
      return advance();
    } else {
      appendToken(TokenType.BAR);
      return next;
    }
  }
  int tokenizeCaret(int next) => select(0x3D, TokenType.CARET_EQ, TokenType.CARET);
  int tokenizeDotOrNumber(int next) {
    int start = offset;
    next = advance();
    if ((0x30 <= next && next <= 0x39)) {
      return tokenizeFractionPart(next, start);
    } else if (0x2E == next) {
      return select(0x2E, TokenType.PERIOD_PERIOD_PERIOD, TokenType.PERIOD_PERIOD);
    } else {
      appendToken(TokenType.PERIOD);
      return next;
    }
  }
  int tokenizeEquals(int next) {
    next = advance();
    if (next == 0x3D) {
      appendToken(TokenType.EQ_EQ);
      return advance();
    } else if (next == 0x3E) {
      appendToken(TokenType.FUNCTION);
      return advance();
    }
    appendToken(TokenType.EQ);
    return next;
  }
  int tokenizeExclamation(int next) {
    next = advance();
    if (next == 0x3D) {
      appendToken(TokenType.BANG_EQ);
      return advance();
    }
    appendToken(TokenType.BANG);
    return next;
  }
  int tokenizeExponent(int next) {
    if (next == 0x2B || next == 0x2D) {
      next = advance();
    }
    bool hasDigits = false;
    while (true) {
      if (0x30 <= next && next <= 0x39) {
        hasDigits = true;
      } else {
        if (!hasDigits) {
          reportError(ScannerErrorCode.MISSING_DIGIT, []);
        }
        return next;
      }
      next = advance();
    }
  }
  int tokenizeFractionPart(int next, int start) {
    bool done = false;
    bool hasDigit = false;
    LOOP: while (!done) {
      if (0x30 <= next && next <= 0x39) {
        hasDigit = true;
      } else if (0x65 == next || 0x45 == next) {
        hasDigit = true;
        next = tokenizeExponent(advance());
        done = true;
        continue LOOP;
      } else {
        done = true;
        continue LOOP;
      }
      next = advance();
    }
    if (!hasDigit) {
      appendStringToken(TokenType.INT, getString(start, -2));
      if (0x2E == next) {
        return select2(0x2E, TokenType.PERIOD_PERIOD_PERIOD, TokenType.PERIOD_PERIOD, offset - 1);
      }
      appendToken2(TokenType.PERIOD, offset - 1);
      return bigSwitch(next);
    }
    if (next == 0x64 || next == 0x44) {
      next = advance();
    }
    appendStringToken(TokenType.DOUBLE, getString(start, next < 0 ? 0 : -1));
    return next;
  }
  int tokenizeGreaterThan(int next) {
    next = advance();
    if (0x3D == next) {
      appendToken(TokenType.GT_EQ);
      return advance();
    } else if (0x3E == next) {
      next = advance();
      if (0x3D == next) {
        appendToken(TokenType.GT_GT_EQ);
        return advance();
      } else {
        appendToken(TokenType.GT_GT);
        return next;
      }
    } else {
      appendToken(TokenType.GT);
      return next;
    }
  }
  int tokenizeHex(int next) {
    int start = offset - 1;
    bool hasDigits = false;
    while (true) {
      next = advance();
      if ((0x30 <= next && next <= 0x39) || (0x41 <= next && next <= 0x46) || (0x61 <= next && next <= 0x66)) {
        hasDigits = true;
      } else {
        if (!hasDigits) {
          reportError(ScannerErrorCode.MISSING_HEX_DIGIT, []);
        }
        appendStringToken(TokenType.HEXADECIMAL, getString(start, next < 0 ? 0 : -1));
        return next;
      }
    }
  }
  int tokenizeHexOrNumber(int next) {
    int x = peek();
    if (x == 0x78 || x == 0x58) {
      advance();
      return tokenizeHex(x);
    }
    return tokenizeNumber(next);
  }
  int tokenizeIdentifier(int next, int start, bool allowDollar) {
    while ((0x61 <= next && next <= 0x7A) || (0x41 <= next && next <= 0x5A) || (0x30 <= next && next <= 0x39) || next == 0x5F || (next == 0x24 && allowDollar) || Character.isLetterOrDigit(next)) {
      next = advance();
    }
    appendStringToken(TokenType.IDENTIFIER, getString(start, next < 0 ? 0 : -1));
    return next;
  }
  int tokenizeInterpolatedExpression(int next, int start) {
    appendBeginToken(TokenType.STRING_INTERPOLATION_EXPRESSION);
    next = advance();
    while (next != -1) {
      if (next == 0x7D) {
        BeginToken begin = findTokenMatchingClosingBraceInInterpolationExpression();
        if (begin == null) {
          beginToken();
          appendToken(TokenType.CLOSE_CURLY_BRACKET);
          next = advance();
          beginToken();
          return next;
        } else if (identical(begin.type, TokenType.OPEN_CURLY_BRACKET)) {
          beginToken();
          appendEndToken(TokenType.CLOSE_CURLY_BRACKET, TokenType.OPEN_CURLY_BRACKET);
          next = advance();
          beginToken();
        } else if (identical(begin.type, TokenType.STRING_INTERPOLATION_EXPRESSION)) {
          beginToken();
          appendEndToken(TokenType.CLOSE_CURLY_BRACKET, TokenType.STRING_INTERPOLATION_EXPRESSION);
          next = advance();
          beginToken();
          return next;
        }
      } else {
        next = bigSwitch(next);
      }
    }
    if (next == -1) {
      return next;
    }
    next = advance();
    beginToken();
    return next;
  }
  int tokenizeInterpolatedIdentifier(int next, int start) {
    appendStringToken2(TokenType.STRING_INTERPOLATION_IDENTIFIER, "\$", 0);
    beginToken();
    next = tokenizeKeywordOrIdentifier(next, false);
    beginToken();
    return next;
  }
  int tokenizeKeywordOrIdentifier(int next2, bool allowDollar) {
    KeywordState state = KeywordState.KEYWORD_STATE;
    int start = offset;
    while (state != null && 0x61 <= next2 && next2 <= 0x7A) {
      state = state.next((next2 as int));
      next2 = advance();
    }
    if (state == null || state.keyword() == null) {
      return tokenizeIdentifier(next2, start, allowDollar);
    }
    if ((0x41 <= next2 && next2 <= 0x5A) || (0x30 <= next2 && next2 <= 0x39) || next2 == 0x5F || next2 == 0x24) {
      return tokenizeIdentifier(next2, start, allowDollar);
    } else if (next2 < 128) {
      appendKeywordToken(state.keyword());
      return next2;
    } else {
      return tokenizeIdentifier(next2, start, allowDollar);
    }
  }
  int tokenizeLessThan(int next) {
    next = advance();
    if (0x3D == next) {
      appendToken(TokenType.LT_EQ);
      return advance();
    } else if (0x3C == next) {
      return select(0x3D, TokenType.LT_LT_EQ, TokenType.LT_LT);
    } else {
      appendToken(TokenType.LT);
      return next;
    }
  }
  int tokenizeMinus(int next) {
    next = advance();
    if (next == 0x2D) {
      appendToken(TokenType.MINUS_MINUS);
      return advance();
    } else if (next == 0x3D) {
      appendToken(TokenType.MINUS_EQ);
      return advance();
    } else {
      appendToken(TokenType.MINUS);
      return next;
    }
  }
  int tokenizeMultiLineComment(int next) {
    int nesting = 1;
    next = advance();
    while (true) {
      if (-1 == next) {
        reportError(ScannerErrorCode.UNTERMINATED_MULTI_LINE_COMMENT, []);
        appendCommentToken(TokenType.MULTI_LINE_COMMENT, getString(_tokenStart, 0));
        return next;
      } else if (0x2A == next) {
        next = advance();
        if (0x2F == next) {
          --nesting;
          if (0 == nesting) {
            appendCommentToken(TokenType.MULTI_LINE_COMMENT, getString(_tokenStart, 0));
            return advance();
          } else {
            next = advance();
          }
        }
      } else if (0x2F == next) {
        next = advance();
        if (0x2A == next) {
          next = advance();
          ++nesting;
        }
      } else {
        next = advance();
      }
    }
  }
  int tokenizeMultiLineRawString(int quoteChar, int start) {
    int next = advance();
    outer: while (next != -1) {
      while (next != quoteChar) {
        next = advance();
        if (next == -1) {
          break outer;
        }
      }
      next = advance();
      if (next == quoteChar) {
        next = advance();
        if (next == quoteChar) {
          appendStringToken(TokenType.STRING, getString(start, 0));
          return advance();
        }
      }
    }
    reportError(ScannerErrorCode.UNTERMINATED_STRING_LITERAL, []);
    appendStringToken(TokenType.STRING, getString(start, 0));
    return advance();
  }
  int tokenizeMultiLineString(int quoteChar, int start, bool raw) {
    if (raw) {
      return tokenizeMultiLineRawString(quoteChar, start);
    }
    int next = advance();
    while (next != -1) {
      if (next == 0x24) {
        appendStringToken(TokenType.STRING, getString(start, -1));
        beginToken();
        next = tokenizeStringInterpolation(start);
        start = offset;
        continue;
      }
      if (next == quoteChar) {
        next = advance();
        if (next == quoteChar) {
          next = advance();
          if (next == quoteChar) {
            appendStringToken(TokenType.STRING, getString(start, 0));
            return advance();
          }
        }
        continue;
      }
      if (next == 0x5C) {
        next = advance();
        if (next == -1) {
          break;
        }
      }
      next = advance();
    }
    reportError(ScannerErrorCode.UNTERMINATED_STRING_LITERAL, []);
    appendStringToken(TokenType.STRING, getString(start, 0));
    return advance();
  }
  int tokenizeMultiply(int next) => select(0x3D, TokenType.STAR_EQ, TokenType.STAR);
  int tokenizeNumber(int next) {
    int start = offset;
    while (true) {
      next = advance();
      if (0x30 <= next && next <= 0x39) {
        continue;
      } else if (next == 0x2E) {
        return tokenizeFractionPart(advance(), start);
      } else if (next == 0x64 || next == 0x44) {
        appendStringToken(TokenType.DOUBLE, getString(start, 0));
        return advance();
      } else if (next == 0x65 || next == 0x45) {
        return tokenizeFractionPart(next, start);
      } else {
        appendStringToken(TokenType.INT, getString(start, next < 0 ? 0 : -1));
        return next;
      }
    }
  }
  int tokenizeOpenSquareBracket(int next) {
    next = advance();
    if (next == 0x5D) {
      return select(0x3D, TokenType.INDEX_EQ, TokenType.INDEX);
    } else {
      appendBeginToken(TokenType.OPEN_SQUARE_BRACKET);
      return next;
    }
  }
  int tokenizePercent(int next) => select(0x3D, TokenType.PERCENT_EQ, TokenType.PERCENT);
  int tokenizePlus(int next) {
    next = advance();
    if (0x2B == next) {
      appendToken(TokenType.PLUS_PLUS);
      return advance();
    } else if (0x3D == next) {
      appendToken(TokenType.PLUS_EQ);
      return advance();
    } else {
      appendToken(TokenType.PLUS);
      return next;
    }
  }
  int tokenizeSingleLineComment(int next) {
    while (true) {
      next = advance();
      if (0xA == next || 0xD == next || -1 == next) {
        appendCommentToken(TokenType.SINGLE_LINE_COMMENT, getString(_tokenStart, 0));
        return next;
      }
    }
  }
  int tokenizeSingleLineRawString(int next, int quoteChar, int start) {
    next = advance();
    while (next != -1) {
      if (next == quoteChar) {
        appendStringToken(TokenType.STRING, getString(start, 0));
        return advance();
      } else if (next == 0xD || next == 0xA) {
        reportError(ScannerErrorCode.UNTERMINATED_STRING_LITERAL, []);
        appendStringToken(TokenType.STRING, getString(start, 0));
        return advance();
      }
      next = advance();
    }
    reportError(ScannerErrorCode.UNTERMINATED_STRING_LITERAL, []);
    appendStringToken(TokenType.STRING, getString(start, 0));
    return advance();
  }
  int tokenizeSingleLineString(int next, int quoteChar, int start) {
    while (next != quoteChar) {
      if (next == 0x5C) {
        next = advance();
      } else if (next == 0x24) {
        appendStringToken(TokenType.STRING, getString(start, -1));
        beginToken();
        next = tokenizeStringInterpolation(start);
        start = offset;
        continue;
      }
      if (next <= 0xD && (next == 0xA || next == 0xD || next == -1)) {
        reportError(ScannerErrorCode.UNTERMINATED_STRING_LITERAL, []);
        appendStringToken(TokenType.STRING, getString(start, 0));
        return advance();
      }
      next = advance();
    }
    appendStringToken(TokenType.STRING, getString(start, 0));
    return advance();
  }
  int tokenizeSlashOrComment(int next) {
    next = advance();
    if (0x2A == next) {
      return tokenizeMultiLineComment(next);
    } else if (0x2F == next) {
      return tokenizeSingleLineComment(next);
    } else if (0x3D == next) {
      appendToken(TokenType.SLASH_EQ);
      return advance();
    } else {
      appendToken(TokenType.SLASH);
      return next;
    }
  }
  int tokenizeString(int next, int start, bool raw) {
    int quoteChar = next;
    next = advance();
    if (quoteChar == next) {
      next = advance();
      if (quoteChar == next) {
        return tokenizeMultiLineString(quoteChar, start, raw);
      } else {
        appendStringToken(TokenType.STRING, getString(start, -1));
        return next;
      }
    }
    if (raw) {
      return tokenizeSingleLineRawString(next, quoteChar, start);
    } else {
      return tokenizeSingleLineString(next, quoteChar, start);
    }
  }
  int tokenizeStringInterpolation(int start) {
    beginToken();
    int next = advance();
    if (next == 0x7B) {
      return tokenizeInterpolatedExpression(next, start);
    } else {
      return tokenizeInterpolatedIdentifier(next, start);
    }
  }
  int tokenizeTag(int next) {
    if (offset == 0) {
      if (peek() == 0x21) {
        do {
          next = advance();
        } while (next != 0xA && next != 0xD && next > 0);
        appendStringToken(TokenType.SCRIPT_TAG, getString(_tokenStart, 0));
        return next;
      }
    }
    appendToken(TokenType.HASH);
    return advance();
  }
  int tokenizeTilde(int next) {
    next = advance();
    if (next == 0x2F) {
      return select(0x3D, TokenType.TILDE_SLASH_EQ, TokenType.TILDE_SLASH);
    } else {
      appendToken(TokenType.TILDE);
      return next;
    }
  }
}
/**
 * Instances of the class {@code StringToken} represent a token whose value is independent of it's
 * type.
 * @coverage dart.engine.parser
 */
class StringToken extends Token {
  /**
   * The lexeme represented by this token.
   */
  String _value2;
  /**
   * Initialize a newly created token to represent a token of the given type with the given value.
   * @param type the type of the token
   * @param value the lexeme represented by this token
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  StringToken(TokenType type, String value, int offset) : super(type, offset) {
    this._value2 = value;
  }
  String get lexeme => _value2;
  String value() => _value2;
}
/**
 * Instances of the class {@code CharBufferScanner} implement a scanner that reads from a character
 * buffer. The scanning logic is in the superclass.
 * @coverage dart.engine.parser
 */
class CharBufferScanner extends AbstractScanner {
  /**
   * The buffer from which characters will be read.
   */
  CharBuffer _buffer;
  /**
   * The number of characters in the buffer.
   */
  int _bufferLength = 0;
  /**
   * The index of the last character that was read.
   */
  int _charOffset = 0;
  /**
   * Initialize a newly created scanner to scan the characters in the given character buffer.
   * @param source the source being scanned
   * @param buffer the buffer from which characters will be read
   * @param errorListener the error listener that will be informed of any errors that are found
   */
  CharBufferScanner(Source source, CharBuffer buffer, AnalysisErrorListener errorListener) : super(source, errorListener) {
    this._buffer = buffer;
    this._bufferLength = buffer.length();
    this._charOffset = -1;
  }
  int get offset => _charOffset;
  int advance() {
    if (_charOffset + 1 >= _bufferLength) {
      return -1;
    }
    return _buffer.charAt(++_charOffset);
  }
  String getString(int start, int endDelta) => _buffer.subSequence(start, _charOffset + 1 + endDelta).toString();
  int peek() {
    if (_charOffset + 1 >= _buffer.length()) {
      return -1;
    }
    return _buffer.charAt(_charOffset + 1);
  }
}
/**
 * Instances of the class {@code TokenWithComment} represent a normal token that is preceded by
 * comments.
 * @coverage dart.engine.parser
 */
class TokenWithComment extends Token {
  /**
   * The first comment in the list of comments that precede this token.
   */
  Token _precedingComment;
  /**
   * Initialize a newly created token to have the given type and offset and to be preceded by the
   * comments reachable from the given comment.
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   * @param precedingComment the first comment in the list of comments that precede this token
   */
  TokenWithComment(TokenType type, int offset, Token precedingComment) : super(type, offset) {
    this._precedingComment = precedingComment;
  }
  Token get precedingComments => _precedingComment;
}
/**
 * Instances of the class {@code Token} represent a token that was scanned from the input. Each
 * token knows which token follows it, acting as the head of a linked list of tokens.
 * @coverage dart.engine.parser
 */
class Token {
  /**
   * The type of the token.
   */
  TokenType _type;
  /**
   * The offset from the beginning of the file to the first character in the token.
   */
  int _offset = 0;
  /**
   * The previous token in the token stream.
   */
  Token _previous;
  /**
   * The next token in the token stream.
   */
  Token _next;
  /**
   * Initialize a newly created token to have the given type and offset.
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  Token(TokenType type, int offset) {
    this._type = type;
    this._offset = offset;
  }
  /**
   * Return the offset from the beginning of the file to the character after last character of the
   * token.
   * @return the offset from the beginning of the file to the first character after last character
   * of the token
   */
  int get end => _offset + length;
  /**
   * Return the number of characters in the node's source range.
   * @return the number of characters in the node's source range
   */
  int get length => lexeme.length;
  /**
   * Return the lexeme that represents this token.
   * @return the lexeme that represents this token
   */
  String get lexeme => _type.lexeme;
  /**
   * Return the next token in the token stream.
   * @return the next token in the token stream
   */
  Token get next => _next;
  /**
   * Return the offset from the beginning of the file to the first character in the token.
   * @return the offset from the beginning of the file to the first character in the token
   */
  int get offset => _offset;
  /**
   * Return the first comment in the list of comments that precede this token, or {@code null} if
   * there are no comments preceding this token. Additional comments can be reached by following the
   * token stream using {@link #getNext()} until {@code null} is returned.
   * @return the first comment in the list of comments that precede this token
   */
  Token get precedingComments => null;
  /**
   * Return the previous token in the token stream.
   * @return the previous token in the token stream
   */
  Token get previous => _previous;
  /**
   * Return the type of the token.
   * @return the type of the token
   */
  TokenType get type => _type;
  /**
   * Return {@code true} if this token represents an operator.
   * @return {@code true} if this token represents an operator
   */
  bool isOperator() => _type.isOperator();
  /**
   * Return {@code true} if this token is a synthetic token. A synthetic token is a token that was
   * introduced by the parser in order to recover from an error in the code. Synthetic tokens always
   * have a length of zero ({@code 0}).
   * @return {@code true} if this token is a synthetic token
   */
  bool isSynthetic() => length == 0;
  /**
   * Return {@code true} if this token represents an operator that can be defined by users.
   * @return {@code true} if this token represents an operator that can be defined by users
   */
  bool isUserDefinableOperator() => _type.isUserDefinableOperator();
  /**
   * Set the next token in the token stream to the given token. This has the side-effect of setting
   * this token to be the previous token for the given token.
   * @param token the next token in the token stream
   * @return the token that was passed in
   */
  Token setNext(Token token) {
    _next = token;
    token.previous = this;
    return token;
  }
  /**
   * Set the next token in the token stream to the given token without changing which token is the
   * previous token for the given token.
   * @param token the next token in the token stream
   * @return the token that was passed in
   */
  Token setNextWithoutSettingPrevious(Token token) {
    _next = token;
    return token;
  }
  /**
   * Set the offset from the beginning of the file to the first character in the token to the given
   * offset.
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  void set offset(int offset4) {
    this._offset = offset4;
  }
  String toString() => lexeme;
  /**
   * Return the value of this token. For keyword tokens, this is the keyword associated with the
   * token, for other tokens it is the lexeme associated with the token.
   * @return the value of this token
   */
  Object value() => _type.lexeme;
  /**
   * Set the previous token in the token stream to the given token.
   * @param previous the previous token in the token stream
   */
  void set previous(Token previous3) {
    this._previous = previous3;
  }
}
/**
 * Instances of the class {@code StringScanner} implement a scanner that reads from a string. The
 * scanning logic is in the superclass.
 * @coverage dart.engine.parser
 */
class StringScanner extends AbstractScanner {
  /**
   * The offset from the beginning of the file to the beginning of the source being scanned.
   */
  int _offsetDelta = 0;
  /**
   * The string from which characters will be read.
   */
  String _string;
  /**
   * The number of characters in the string.
   */
  int _stringLength = 0;
  /**
   * The index, relative to the string, of the last character that was read.
   */
  int _charOffset = 0;
  /**
   * Initialize a newly created scanner to scan the characters in the given string.
   * @param source the source being scanned
   * @param string the string from which characters will be read
   * @param errorListener the error listener that will be informed of any errors that are found
   */
  StringScanner(Source source, String string, AnalysisErrorListener errorListener) : super(source, errorListener) {
    this._offsetDelta = 0;
    this._string = string;
    this._stringLength = string.length;
    this._charOffset = -1;
  }
  int get offset => _offsetDelta + _charOffset;
  /**
   * Record that the source begins on the given line and column at the given offset. The line starts
   * for lines before the given line will not be correct.
   * <p>
   * This method must be invoked at most one time and must be invoked before scanning begins. The
   * values provided must be sensible. The results are undefined if these conditions are violated.
   * @param line the one-based index of the line containing the first character of the source
   * @param column the one-based index of the column in which the first character of the source
   * occurs
   * @param offset the zero-based offset from the beginning of the larger context to the first
   * character of the source
   */
  void setSourceStart(int line, int column, int offset) {
    if (line < 1 || column < 1 || offset < 0 || (line + column - 2) >= offset) {
      return;
    }
    _offsetDelta = 1;
    for (int i = 2; i < line; i++) {
      recordStartOfLine();
    }
    _offsetDelta = offset - column + 1;
    recordStartOfLine();
    _offsetDelta = offset;
  }
  int advance() {
    if (_charOffset + 1 >= _stringLength) {
      return -1;
    }
    return _string.codeUnitAt(++_charOffset);
  }
  String getString(int start, int endDelta) => _string.substring(start - _offsetDelta, _charOffset + 1 + endDelta);
  int peek() {
    if (_charOffset + 1 >= _string.length) {
      return -1;
    }
    return _string.codeUnitAt(_charOffset + 1);
  }
}
/**
 * Instances of the class {@code BeginTokenWithComment} represent a begin token that is preceded by
 * comments.
 * @coverage dart.engine.parser
 */
class BeginTokenWithComment extends BeginToken {
  /**
   * The first comment in the list of comments that precede this token.
   */
  Token _precedingComment;
  /**
   * Initialize a newly created token to have the given type and offset and to be preceded by the
   * comments reachable from the given comment.
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   * @param precedingComment the first comment in the list of comments that precede this token
   */
  BeginTokenWithComment(TokenType type, int offset, Token precedingComment) : super(type, offset) {
    this._precedingComment = precedingComment;
  }
  Token get precedingComments => _precedingComment;
}
/**
 * Instances of the class {@code KeywordToken} represent a keyword in the language.
 * @coverage dart.engine.parser
 */
class KeywordToken extends Token {
  /**
   * The keyword being represented by this token.
   */
  Keyword _keyword;
  /**
   * Initialize a newly created token to represent the given keyword.
   * @param keyword the keyword being represented by this token
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  KeywordToken(Keyword keyword, int offset) : super(TokenType.KEYWORD, offset) {
    this._keyword = keyword;
  }
  /**
   * Return the keyword being represented by this token.
   * @return the keyword being represented by this token
   */
  Keyword get keyword => _keyword;
  String get lexeme => _keyword.syntax;
  Keyword value() => _keyword;
}
/**
 * Instances of the class {@code BeginToken} represent the opening half of a grouping pair of
 * tokens. This is used for curly brackets ('{'), parentheses ('('), and square brackets ('[').
 * @coverage dart.engine.parser
 */
class BeginToken extends Token {
  /**
   * The token that corresponds to this token.
   */
  Token _endToken;
  /**
   * Initialize a newly created token representing the opening half of a grouping pair of tokens.
   * @param type the type of the token
   * @param offset the offset from the beginning of the file to the first character in the token
   */
  BeginToken(TokenType type, int offset) : super(type, offset) {
    assert((identical(type, TokenType.OPEN_CURLY_BRACKET) || identical(type, TokenType.OPEN_PAREN) || identical(type, TokenType.OPEN_SQUARE_BRACKET) || identical(type, TokenType.STRING_INTERPOLATION_EXPRESSION)));
  }
  /**
   * Return the token that corresponds to this token.
   * @return the token that corresponds to this token
   */
  Token get endToken => _endToken;
  /**
   * Set the token that corresponds to this token to the given token.
   * @param token the token that corresponds to this token
   */
  void set endToken(Token token) {
    this._endToken = token;
  }
}
/**
 * The enumeration {@code TokenClass} represents classes (or groups) of tokens with a similar use.
 * @coverage dart.engine.parser
 */
class TokenClass {
  /**
   * A value used to indicate that the token type is not part of any specific class of token.
   */
  static final TokenClass NO_CLASS = new TokenClass.con1('NO_CLASS', 0);
  /**
   * A value used to indicate that the token type is an additive operator.
   */
  static final TokenClass ADDITIVE_OPERATOR = new TokenClass.con2('ADDITIVE_OPERATOR', 1, 12);
  /**
   * A value used to indicate that the token type is an assignment operator.
   */
  static final TokenClass ASSIGNMENT_OPERATOR = new TokenClass.con2('ASSIGNMENT_OPERATOR', 2, 1);
  /**
   * A value used to indicate that the token type is a bitwise-and operator.
   */
  static final TokenClass BITWISE_AND_OPERATOR = new TokenClass.con2('BITWISE_AND_OPERATOR', 3, 8);
  /**
   * A value used to indicate that the token type is a bitwise-or operator.
   */
  static final TokenClass BITWISE_OR_OPERATOR = new TokenClass.con2('BITWISE_OR_OPERATOR', 4, 6);
  /**
   * A value used to indicate that the token type is a bitwise-xor operator.
   */
  static final TokenClass BITWISE_XOR_OPERATOR = new TokenClass.con2('BITWISE_XOR_OPERATOR', 5, 7);
  /**
   * A value used to indicate that the token type is a cascade operator.
   */
  static final TokenClass CASCADE_OPERATOR = new TokenClass.con2('CASCADE_OPERATOR', 6, 2);
  /**
   * A value used to indicate that the token type is a conditional operator.
   */
  static final TokenClass CONDITIONAL_OPERATOR = new TokenClass.con2('CONDITIONAL_OPERATOR', 7, 3);
  /**
   * A value used to indicate that the token type is an equality operator.
   */
  static final TokenClass EQUALITY_OPERATOR = new TokenClass.con2('EQUALITY_OPERATOR', 8, 9);
  /**
   * A value used to indicate that the token type is a logical-and operator.
   */
  static final TokenClass LOGICAL_AND_OPERATOR = new TokenClass.con2('LOGICAL_AND_OPERATOR', 9, 5);
  /**
   * A value used to indicate that the token type is a logical-or operator.
   */
  static final TokenClass LOGICAL_OR_OPERATOR = new TokenClass.con2('LOGICAL_OR_OPERATOR', 10, 4);
  /**
   * A value used to indicate that the token type is a multiplicative operator.
   */
  static final TokenClass MULTIPLICATIVE_OPERATOR = new TokenClass.con2('MULTIPLICATIVE_OPERATOR', 11, 13);
  /**
   * A value used to indicate that the token type is a relational operator.
   */
  static final TokenClass RELATIONAL_OPERATOR = new TokenClass.con2('RELATIONAL_OPERATOR', 12, 10);
  /**
   * A value used to indicate that the token type is a shift operator.
   */
  static final TokenClass SHIFT_OPERATOR = new TokenClass.con2('SHIFT_OPERATOR', 13, 11);
  /**
   * A value used to indicate that the token type is a unary operator.
   */
  static final TokenClass UNARY_POSTFIX_OPERATOR = new TokenClass.con2('UNARY_POSTFIX_OPERATOR', 14, 15);
  /**
   * A value used to indicate that the token type is a unary operator.
   */
  static final TokenClass UNARY_PREFIX_OPERATOR = new TokenClass.con2('UNARY_PREFIX_OPERATOR', 15, 14);
  static final List<TokenClass> values = [NO_CLASS, ADDITIVE_OPERATOR, ASSIGNMENT_OPERATOR, BITWISE_AND_OPERATOR, BITWISE_OR_OPERATOR, BITWISE_XOR_OPERATOR, CASCADE_OPERATOR, CONDITIONAL_OPERATOR, EQUALITY_OPERATOR, LOGICAL_AND_OPERATOR, LOGICAL_OR_OPERATOR, MULTIPLICATIVE_OPERATOR, RELATIONAL_OPERATOR, SHIFT_OPERATOR, UNARY_POSTFIX_OPERATOR, UNARY_PREFIX_OPERATOR];
  String __name;
  int __ordinal = 0;
  int get ordinal => __ordinal;
  /**
   * The precedence of tokens of this class, or {@code 0} if the such tokens do not represent an
   * operator.
   */
  int _precedence = 0;
  TokenClass.con1(String ___name, int ___ordinal) {
    _jtd_constructor_288_impl(___name, ___ordinal);
  }
  _jtd_constructor_288_impl(String ___name, int ___ordinal) {
    _jtd_constructor_289_impl(___name, ___ordinal, 0);
  }
  TokenClass.con2(String ___name, int ___ordinal, int precedence2) {
    _jtd_constructor_289_impl(___name, ___ordinal, precedence2);
  }
  _jtd_constructor_289_impl(String ___name, int ___ordinal, int precedence2) {
    __name = ___name;
    __ordinal = ___ordinal;
    this._precedence = precedence2;
  }
  /**
   * Return the precedence of tokens of this class, or {@code 0} if the such tokens do not represent
   * an operator.
   * @return the precedence of tokens of this class
   */
  int get precedence => _precedence;
  String toString() => __name;
}
/**
 * Instances of the class {@code KeywordTokenWithComment} implement a keyword token that is preceded
 * by comments.
 * @coverage dart.engine.parser
 */
class KeywordTokenWithComment extends KeywordToken {
  /**
   * The first comment in the list of comments that precede this token.
   */
  Token _precedingComment;
  /**
   * Initialize a newly created token to to represent the given keyword and to be preceded by the
   * comments reachable from the given comment.
   * @param keyword the keyword being represented by this token
   * @param offset the offset from the beginning of the file to the first character in the token
   * @param precedingComment the first comment in the list of comments that precede this token
   */
  KeywordTokenWithComment(Keyword keyword, int offset, Token precedingComment) : super(keyword, offset) {
    this._precedingComment = precedingComment;
  }
  Token get precedingComments => _precedingComment;
}
/**
 * The enumeration {@code TokenType} defines the types of tokens that can be returned by the
 * scanner.
 * @coverage dart.engine.parser
 */
class TokenType {
  /**
   * The type of the token that marks the end of the input.
   */
  static final TokenType EOF = new TokenType_EOF('EOF', 0, null, "");
  static final TokenType DOUBLE = new TokenType.con1('DOUBLE', 1);
  static final TokenType HEXADECIMAL = new TokenType.con1('HEXADECIMAL', 2);
  static final TokenType IDENTIFIER = new TokenType.con1('IDENTIFIER', 3);
  static final TokenType INT = new TokenType.con1('INT', 4);
  static final TokenType KEYWORD = new TokenType.con1('KEYWORD', 5);
  static final TokenType MULTI_LINE_COMMENT = new TokenType.con1('MULTI_LINE_COMMENT', 6);
  static final TokenType SCRIPT_TAG = new TokenType.con1('SCRIPT_TAG', 7);
  static final TokenType SINGLE_LINE_COMMENT = new TokenType.con1('SINGLE_LINE_COMMENT', 8);
  static final TokenType STRING = new TokenType.con1('STRING', 9);
  static final TokenType AMPERSAND = new TokenType.con2('AMPERSAND', 10, TokenClass.BITWISE_AND_OPERATOR, "&");
  static final TokenType AMPERSAND_AMPERSAND = new TokenType.con2('AMPERSAND_AMPERSAND', 11, TokenClass.LOGICAL_AND_OPERATOR, "&&");
  static final TokenType AMPERSAND_EQ = new TokenType.con2('AMPERSAND_EQ', 12, TokenClass.ASSIGNMENT_OPERATOR, "&=");
  static final TokenType AT = new TokenType.con2('AT', 13, null, "@");
  static final TokenType BANG = new TokenType.con2('BANG', 14, TokenClass.UNARY_PREFIX_OPERATOR, "!");
  static final TokenType BANG_EQ = new TokenType.con2('BANG_EQ', 15, TokenClass.EQUALITY_OPERATOR, "!=");
  static final TokenType BAR = new TokenType.con2('BAR', 16, TokenClass.BITWISE_OR_OPERATOR, "|");
  static final TokenType BAR_BAR = new TokenType.con2('BAR_BAR', 17, TokenClass.LOGICAL_OR_OPERATOR, "||");
  static final TokenType BAR_EQ = new TokenType.con2('BAR_EQ', 18, TokenClass.ASSIGNMENT_OPERATOR, "|=");
  static final TokenType COLON = new TokenType.con2('COLON', 19, null, ":");
  static final TokenType COMMA = new TokenType.con2('COMMA', 20, null, ",");
  static final TokenType CARET = new TokenType.con2('CARET', 21, TokenClass.BITWISE_XOR_OPERATOR, "^");
  static final TokenType CARET_EQ = new TokenType.con2('CARET_EQ', 22, TokenClass.ASSIGNMENT_OPERATOR, "^=");
  static final TokenType CLOSE_CURLY_BRACKET = new TokenType.con2('CLOSE_CURLY_BRACKET', 23, null, "}");
  static final TokenType CLOSE_PAREN = new TokenType.con2('CLOSE_PAREN', 24, null, ")");
  static final TokenType CLOSE_SQUARE_BRACKET = new TokenType.con2('CLOSE_SQUARE_BRACKET', 25, null, "]");
  static final TokenType EQ = new TokenType.con2('EQ', 26, TokenClass.ASSIGNMENT_OPERATOR, "=");
  static final TokenType EQ_EQ = new TokenType.con2('EQ_EQ', 27, TokenClass.EQUALITY_OPERATOR, "==");
  static final TokenType FUNCTION = new TokenType.con2('FUNCTION', 28, null, "=>");
  static final TokenType GT = new TokenType.con2('GT', 29, TokenClass.RELATIONAL_OPERATOR, ">");
  static final TokenType GT_EQ = new TokenType.con2('GT_EQ', 30, TokenClass.RELATIONAL_OPERATOR, ">=");
  static final TokenType GT_GT = new TokenType.con2('GT_GT', 31, TokenClass.SHIFT_OPERATOR, ">>");
  static final TokenType GT_GT_EQ = new TokenType.con2('GT_GT_EQ', 32, TokenClass.ASSIGNMENT_OPERATOR, ">>=");
  static final TokenType HASH = new TokenType.con2('HASH', 33, null, "#");
  static final TokenType INDEX = new TokenType.con2('INDEX', 34, TokenClass.UNARY_POSTFIX_OPERATOR, "[]");
  static final TokenType INDEX_EQ = new TokenType.con2('INDEX_EQ', 35, TokenClass.UNARY_POSTFIX_OPERATOR, "[]=");
  static final TokenType IS = new TokenType.con2('IS', 36, TokenClass.RELATIONAL_OPERATOR, "is");
  static final TokenType LT = new TokenType.con2('LT', 37, TokenClass.RELATIONAL_OPERATOR, "<");
  static final TokenType LT_EQ = new TokenType.con2('LT_EQ', 38, TokenClass.RELATIONAL_OPERATOR, "<=");
  static final TokenType LT_LT = new TokenType.con2('LT_LT', 39, TokenClass.SHIFT_OPERATOR, "<<");
  static final TokenType LT_LT_EQ = new TokenType.con2('LT_LT_EQ', 40, TokenClass.ASSIGNMENT_OPERATOR, "<<=");
  static final TokenType MINUS = new TokenType.con2('MINUS', 41, TokenClass.ADDITIVE_OPERATOR, "-");
  static final TokenType MINUS_EQ = new TokenType.con2('MINUS_EQ', 42, TokenClass.ASSIGNMENT_OPERATOR, "-=");
  static final TokenType MINUS_MINUS = new TokenType.con2('MINUS_MINUS', 43, TokenClass.UNARY_PREFIX_OPERATOR, "--");
  static final TokenType OPEN_CURLY_BRACKET = new TokenType.con2('OPEN_CURLY_BRACKET', 44, null, "{");
  static final TokenType OPEN_PAREN = new TokenType.con2('OPEN_PAREN', 45, TokenClass.UNARY_POSTFIX_OPERATOR, "(");
  static final TokenType OPEN_SQUARE_BRACKET = new TokenType.con2('OPEN_SQUARE_BRACKET', 46, TokenClass.UNARY_POSTFIX_OPERATOR, "[");
  static final TokenType PERCENT = new TokenType.con2('PERCENT', 47, TokenClass.MULTIPLICATIVE_OPERATOR, "%");
  static final TokenType PERCENT_EQ = new TokenType.con2('PERCENT_EQ', 48, TokenClass.ASSIGNMENT_OPERATOR, "%=");
  static final TokenType PERIOD = new TokenType.con2('PERIOD', 49, TokenClass.UNARY_POSTFIX_OPERATOR, ".");
  static final TokenType PERIOD_PERIOD = new TokenType.con2('PERIOD_PERIOD', 50, TokenClass.CASCADE_OPERATOR, "..");
  static final TokenType PLUS = new TokenType.con2('PLUS', 51, TokenClass.ADDITIVE_OPERATOR, "+");
  static final TokenType PLUS_EQ = new TokenType.con2('PLUS_EQ', 52, TokenClass.ASSIGNMENT_OPERATOR, "+=");
  static final TokenType PLUS_PLUS = new TokenType.con2('PLUS_PLUS', 53, TokenClass.UNARY_PREFIX_OPERATOR, "++");
  static final TokenType QUESTION = new TokenType.con2('QUESTION', 54, TokenClass.CONDITIONAL_OPERATOR, "?");
  static final TokenType SEMICOLON = new TokenType.con2('SEMICOLON', 55, null, ";");
  static final TokenType SLASH = new TokenType.con2('SLASH', 56, TokenClass.MULTIPLICATIVE_OPERATOR, "/");
  static final TokenType SLASH_EQ = new TokenType.con2('SLASH_EQ', 57, TokenClass.ASSIGNMENT_OPERATOR, "/=");
  static final TokenType STAR = new TokenType.con2('STAR', 58, TokenClass.MULTIPLICATIVE_OPERATOR, "*");
  static final TokenType STAR_EQ = new TokenType.con2('STAR_EQ', 59, TokenClass.ASSIGNMENT_OPERATOR, "*=");
  static final TokenType STRING_INTERPOLATION_EXPRESSION = new TokenType.con2('STRING_INTERPOLATION_EXPRESSION', 60, null, "\${");
  static final TokenType STRING_INTERPOLATION_IDENTIFIER = new TokenType.con2('STRING_INTERPOLATION_IDENTIFIER', 61, null, "\$");
  static final TokenType TILDE = new TokenType.con2('TILDE', 62, TokenClass.UNARY_PREFIX_OPERATOR, "~");
  static final TokenType TILDE_SLASH = new TokenType.con2('TILDE_SLASH', 63, TokenClass.MULTIPLICATIVE_OPERATOR, "~/");
  static final TokenType TILDE_SLASH_EQ = new TokenType.con2('TILDE_SLASH_EQ', 64, TokenClass.ASSIGNMENT_OPERATOR, "~/=");
  static final TokenType BACKPING = new TokenType.con2('BACKPING', 65, null, "`");
  static final TokenType BACKSLASH = new TokenType.con2('BACKSLASH', 66, null, "\\");
  static final TokenType PERIOD_PERIOD_PERIOD = new TokenType.con2('PERIOD_PERIOD_PERIOD', 67, null, "...");
  static final List<TokenType> values = [EOF, DOUBLE, HEXADECIMAL, IDENTIFIER, INT, KEYWORD, MULTI_LINE_COMMENT, SCRIPT_TAG, SINGLE_LINE_COMMENT, STRING, AMPERSAND, AMPERSAND_AMPERSAND, AMPERSAND_EQ, AT, BANG, BANG_EQ, BAR, BAR_BAR, BAR_EQ, COLON, COMMA, CARET, CARET_EQ, CLOSE_CURLY_BRACKET, CLOSE_PAREN, CLOSE_SQUARE_BRACKET, EQ, EQ_EQ, FUNCTION, GT, GT_EQ, GT_GT, GT_GT_EQ, HASH, INDEX, INDEX_EQ, IS, LT, LT_EQ, LT_LT, LT_LT_EQ, MINUS, MINUS_EQ, MINUS_MINUS, OPEN_CURLY_BRACKET, OPEN_PAREN, OPEN_SQUARE_BRACKET, PERCENT, PERCENT_EQ, PERIOD, PERIOD_PERIOD, PLUS, PLUS_EQ, PLUS_PLUS, QUESTION, SEMICOLON, SLASH, SLASH_EQ, STAR, STAR_EQ, STRING_INTERPOLATION_EXPRESSION, STRING_INTERPOLATION_IDENTIFIER, TILDE, TILDE_SLASH, TILDE_SLASH_EQ, BACKPING, BACKSLASH, PERIOD_PERIOD_PERIOD];
  String __name;
  int __ordinal = 0;
  int get ordinal => __ordinal;
  /**
   * The class of the token.
   */
  TokenClass _tokenClass;
  /**
   * The lexeme that defines this type of token, or {@code null} if there is more than one possible
   * lexeme for this type of token.
   */
  String _lexeme;
  TokenType.con1(String ___name, int ___ordinal) {
    _jtd_constructor_290_impl(___name, ___ordinal);
  }
  _jtd_constructor_290_impl(String ___name, int ___ordinal) {
    _jtd_constructor_291_impl(___name, ___ordinal, TokenClass.NO_CLASS, null);
  }
  TokenType.con2(String ___name, int ___ordinal, TokenClass tokenClass2, String lexeme2) {
    _jtd_constructor_291_impl(___name, ___ordinal, tokenClass2, lexeme2);
  }
  _jtd_constructor_291_impl(String ___name, int ___ordinal, TokenClass tokenClass2, String lexeme2) {
    __name = ___name;
    __ordinal = ___ordinal;
    this._tokenClass = tokenClass2 == null ? TokenClass.NO_CLASS : tokenClass2;
    this._lexeme = lexeme2;
  }
  /**
   * Return the lexeme that defines this type of token, or {@code null} if there is more than one
   * possible lexeme for this type of token.
   * @return the lexeme that defines this type of token
   */
  String get lexeme => _lexeme;
  /**
   * Return the precedence of the token, or {@code 0} if the token does not represent an operator.
   * @return the precedence of the token
   */
  int get precedence => _tokenClass.precedence;
  /**
   * Return {@code true} if this type of token represents an additive operator.
   * @return {@code true} if this type of token represents an additive operator
   */
  bool isAdditiveOperator() => identical(_tokenClass, TokenClass.ADDITIVE_OPERATOR);
  /**
   * Return {@code true} if this type of token represents an assignment operator.
   * @return {@code true} if this type of token represents an assignment operator
   */
  bool isAssignmentOperator() => identical(_tokenClass, TokenClass.ASSIGNMENT_OPERATOR);
  /**
   * Return {@code true} if this type of token represents an associative operator. An associative
   * operator is an operator for which the following equality is true:{@code (a * b) * c == a * (b * c)}. In other words, if the result of applying the operator to
   * multiple operands does not depend on the order in which those applications occur.
   * <p>
   * Note: This method considers the logical-and and logical-or operators to be associative, even
   * though the order in which the application of those operators can have an effect because
   * evaluation of the right-hand operand is conditional.
   * @return {@code true} if this type of token represents an associative operator
   */
  bool isAssociativeOperator() => identical(this, AMPERSAND) || identical(this, AMPERSAND_AMPERSAND) || identical(this, BAR) || identical(this, BAR_BAR) || identical(this, CARET) || identical(this, PLUS) || identical(this, STAR);
  /**
   * Return {@code true} if this type of token represents an equality operator.
   * @return {@code true} if this type of token represents an equality operator
   */
  bool isEqualityOperator() => identical(_tokenClass, TokenClass.EQUALITY_OPERATOR);
  /**
   * Return {@code true} if this type of token represents an increment operator.
   * @return {@code true} if this type of token represents an increment operator
   */
  bool isIncrementOperator() => identical(_lexeme, "++") || identical(_lexeme, "--");
  /**
   * Return {@code true} if this type of token represents a multiplicative operator.
   * @return {@code true} if this type of token represents a multiplicative operator
   */
  bool isMultiplicativeOperator() => identical(_tokenClass, TokenClass.MULTIPLICATIVE_OPERATOR);
  /**
   * Return {@code true} if this token type represents an operator.
   * @return {@code true} if this token type represents an operator
   */
  bool isOperator() => _tokenClass != TokenClass.NO_CLASS && this != OPEN_PAREN && this != OPEN_SQUARE_BRACKET && this != PERIOD;
  /**
   * Return {@code true} if this type of token represents a relational operator.
   * @return {@code true} if this type of token represents a relational operator
   */
  bool isRelationalOperator() => identical(_tokenClass, TokenClass.RELATIONAL_OPERATOR);
  /**
   * Return {@code true} if this type of token represents a shift operator.
   * @return {@code true} if this type of token represents a shift operator
   */
  bool isShiftOperator() => identical(_tokenClass, TokenClass.SHIFT_OPERATOR);
  /**
   * Return {@code true} if this type of token represents a unary postfix operator.
   * @return {@code true} if this type of token represents a unary postfix operator
   */
  bool isUnaryPostfixOperator() => identical(_tokenClass, TokenClass.UNARY_POSTFIX_OPERATOR);
  /**
   * Return {@code true} if this type of token represents a unary prefix operator.
   * @return {@code true} if this type of token represents a unary prefix operator
   */
  bool isUnaryPrefixOperator() => identical(_tokenClass, TokenClass.UNARY_PREFIX_OPERATOR);
  /**
   * Return {@code true} if this token type represents an operator that can be defined by users.
   * @return {@code true} if this token type represents an operator that can be defined by users
   */
  bool isUserDefinableOperator() => identical(_lexeme, "==") || identical(_lexeme, "~") || identical(_lexeme, "[]") || identical(_lexeme, "[]=") || identical(_lexeme, "*") || identical(_lexeme, "/") || identical(_lexeme, "%") || identical(_lexeme, "~/") || identical(_lexeme, "+") || identical(_lexeme, "-") || identical(_lexeme, "<<") || identical(_lexeme, ">>") || identical(_lexeme, ">=") || identical(_lexeme, ">") || identical(_lexeme, "<=") || identical(_lexeme, "<") || identical(_lexeme, "&") || identical(_lexeme, "^") || identical(_lexeme, "|");
  String toString() => __name;
}
class TokenType_EOF extends TokenType {
  TokenType_EOF(String ___name, int ___ordinal, TokenClass arg0, String arg1) : super.con2(___name, ___ordinal, arg0, arg1);
  String toString() => "-eof-";
}