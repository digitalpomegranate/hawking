enum Commands { New, Select, Set }

class SToC {
  Commands lastCommand = Commands.New;

  String code = '#next';

  void command(String text) {
    text = text.toLowerCase();

    switch (text) {
      case 'new':
        lastCommand = Commands.New;
        if (code == '#next') {
          code = codeReplace('''
            Scafold(
              body: #next
            )
           ''');
        }
        return;
        break;
      case 'select':
        lastCommand = Commands.Select;
        return;
        break;

      case 'set':
        lastCommand = Commands.Set;
        return;
        break;
      default:
    }

    switch (lastCommand) {
      case Commands.New:
        // very beggining

        code = codeReplace(parseValue(text));

        break;
      case Commands.Select:
        code = codeReplace(parseProperty(text));
        break;
      case Commands.Set:
        code = codeReplace(parseValue(text));
        break;
      default:
    }
  }

  codeReplace(String value) {
    if (value != '') {
      return code.replaceFirst('#next', value);
    }

    return code;
  }

  parseCommand(String text) {}

  String parseProperty(String text) {
    if (text.toLowerCase().contains('child')) {
      return '''child:#next
      ''';
    } else if (text.toLowerCase().contains('')) {
      return '''Text(
                #next
              ),''';
    } else if (text.toLowerCase().contains('center')) {
      return '''Center(
                #next
                ),''';
    } else {
      return '';
    }
  }

  String parseValue(String text) {
    if (text.toLowerCase().contains('container')) {
      return '''Container(
            #next
            ),''';
    } else if (text.toLowerCase().contains('text')) {
      return '''Text(
                #next
              ),''';
    } else if (text.toLowerCase().contains('center')) {
      return '''Center(
                #next
                ),''';
    } else {
      return text;
    }
  }
}
