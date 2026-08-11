/// Indian government / competitive exam options (keys match backend config/exams.php).
class ExamOption {
  const ExamOption({required this.key, required this.label});

  final String key;
  final String label;
}

class ExamCatalog {
  ExamCatalog._();

  static const List<ExamOption> defaults = [
    ExamOption(key: 'super_tet', label: 'Super TET'),
    ExamOption(key: 'up_tet', label: 'UP TET'),
    ExamOption(key: 'ctet', label: 'CTET'),
    ExamOption(key: 'uptet', label: 'UPTET'),
    ExamOption(key: 'up_police', label: 'UP Police'),
    ExamOption(key: 'up_si', label: 'UP SI / Daroga'),
    ExamOption(key: 'ssc_cgl', label: 'SSC CGL'),
    ExamOption(key: 'ssc_chsl', label: 'SSC CHSL'),
    ExamOption(key: 'ssc_gd', label: 'SSC GD'),
    ExamOption(key: 'ssc_mts', label: 'SSC MTS'),
    ExamOption(key: 'railway_ntpc', label: 'Railway NTPC'),
    ExamOption(key: 'railway_group_d', label: 'Railway Group D'),
    ExamOption(key: 'upsc_cse', label: 'UPSC CSE'),
    ExamOption(key: 'uppsc', label: 'UPPSC PCS'),
    ExamOption(key: 'bpsc', label: 'BPSC'),
    ExamOption(key: 'mppsc', label: 'MPPSC'),
    ExamOption(key: 'ibps_po', label: 'IBPS PO'),
    ExamOption(key: 'ibps_clerk', label: 'IBPS Clerk'),
    ExamOption(key: 'sbi_po', label: 'SBI PO'),
    ExamOption(key: 'sbi_clerk', label: 'SBI Clerk'),
    ExamOption(key: 'rbi_grade_b', label: 'RBI Grade B'),
    ExamOption(key: 'nda', label: 'NDA'),
    ExamOption(key: 'cds', label: 'CDS'),
    ExamOption(key: 'capf', label: 'CAPF'),
    ExamOption(key: 'state_pcs', label: 'State PCS'),
    ExamOption(key: 'other', label: 'Other Govt Exam'),
  ];

  static String labelFor(String key) {
    for (final o in defaults) {
      if (o.key == key) return o.label;
    }
    return key;
  }
}
