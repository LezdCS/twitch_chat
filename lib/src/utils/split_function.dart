List parseMessage (String message) {

  List<String> keys = [
    "PRIVMSG",
    "CLEARCHAT",
    "CLEARMSG",
    "USERNOTICE",
    "NOTICE",
    "ROOMSTATE"
  ];
      
  int i = 0;
  for(var key in keys){
    i = message.indexOf(key);
    if(i > 0){
      break;
    }
  }
  String sub = message.substring(0, i - 1);
  String notToSplit = message.substring(i);
  List messageSplited = sub.split(';');
  messageSplited[messageSplited.length-1] = messageSplited[messageSplited.length-1] + ' ' + notToSplit;
  return messageSplited;
}