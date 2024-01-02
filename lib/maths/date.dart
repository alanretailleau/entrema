String textDate({required DateTime date, required bool fr}) {
  String text = "";
  if (DateTime.now().isBefore(date)) {
    text += fr ? "Dans " : "In ";
  } else if (fr) {
    text += "Il y a ";
  }
  Duration difference = DateTime.now().difference(date).abs();
  if (difference.inDays >= 365 && difference.inDays < 730) {
    text += "${(difference.inDays / 365).round()}";
    text += fr ? " an" : " year";
  } else if (difference.inDays >= 730) {
    text += "${(difference.inDays / 365).round()}";
    text += fr ? " ans" : " years";
  } else if (difference.inDays >= 31) {
    text += "${(difference.inDays / 31).round()}";
    text += fr ? " mois" : " month.s";
  } else if (difference.inDays >= 7 && difference.inDays < 14) {
    text += "${(difference.inDays).floor()}";
    text += fr ? " jours" : " days";
  } else if (difference.inDays >= 14) {
    text += "${(difference.inDays / 7).round()}";
    text += fr ? " semaines" : " weeks";
  } else if (difference.inDays > 1) {
    text += "${difference.inDays}";
    text += fr ? " jours" : " days";
  } else if (difference.inDays == 1) {
    text += "${difference.inDays}";
    text += fr ? " jour" : " day";
  } else if (difference.inHours > 1) {
    text += "${difference.inHours}";
    text += fr ? " heures" : " hours";
  } else if (difference.inHours == 1) {
    text += "${difference.inHours}";
    text += fr ? " heure" : " hour";
  } else if (difference.inMinutes > 1) {
    text += "${difference.inMinutes} minutes";
  } else if (difference.inMinutes == 1) {
    text += "${difference.inMinutes} minute";
  } else {
    text = fr ? "Récemment" : "Recently";
  }
  if (!fr && DateTime.now().isAfter(date)) {
    text += " ago";
  }
  return text;
}

String durationText(
    {required Duration duration, required bool fr, required int precision}) {
  String text = "";
  if (duration.inDays >= 365 && duration.inDays < 730) {
    text += "${(duration.inDays / 365).round()}";
    text += fr ? " an" : " year";
  } else if (duration.inDays >= 730) {
    text += "${(duration.inDays / 365).round()}";
    text += fr ? " ans" : " years";
  } else if (duration.inDays >= 31) {
    text += "${(duration.inDays / 31).round()}";
    text += fr ? " mois" : " month.s";
  } else if (duration.inDays >= 7 && duration.inDays < 14) {
    text += "${(duration.inDays).floor()}";
    text += fr ? " jours" : " days";
  } else if (duration.inDays >= 14) {
    text += "${(duration.inDays / 7).round()}";
    text += fr ? " semaines" : " weeks";
  } else if (duration.inDays > 1) {
    text += "${duration.inDays}";
    text += fr ? " jours" : " days";
  } else if (duration.inDays == 1) {
    text += "${duration.inDays}";
    text += fr ? " jour" : " day";
  } else if (duration.inHours > 1) {
    text += "${duration.inHours}";
    text += "h";
    text += "${duration.inMinutes - duration.inHours * 60}";
    text += "min";
  } else if (duration.inHours == 1) {
    text += "${duration.inHours}";
    text += "h";
    text += "${duration.inMinutes - duration.inHours * 60}";
    text += "min";
  } else if (duration.inMinutes >= 1) {
    text += "${duration.inMinutes}min";
    text += duration.inSeconds - duration.inMinutes * 60 < 10
        ? duration.inSeconds - duration.inMinutes * 60 == 0
            ? " 00s"
            : " 0${duration.inSeconds - duration.inMinutes * 60}s"
        : " ${duration.inSeconds - duration.inMinutes * 60}s";
  } else {
    text += duration.inSeconds < 10
        ? "0${duration.inSeconds}s"
        : "${duration.inSeconds}s";
  }

  return text;
}
