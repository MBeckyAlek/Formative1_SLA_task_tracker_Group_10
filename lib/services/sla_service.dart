// STUB by A: Person B overwrites this file
import '../models/enums.dart';
import '../models/task.dart';

class SlaService {
  static SlaStatus compute(Task task, {DateTime? now}) => SlaStatus.onTrack;
}
