import '../../features/incidents/domain/incident_category.dart';
import '../../features/incidents/domain/incident_severity.dart';

class TypeRule {
  final String type;
  final Set<String> keywords;
  final IncidentSeverity baseSeverity;

  const TypeRule(this.type, this.keywords, this.baseSeverity);
}

const Map<IncidentCategory, List<TypeRule>> kCategoryTypes = {
  IncidentCategory.fire: [
    TypeRule('structure_fire',
        {'house', 'home', 'building', 'apartment', 'roof', 'shop', 'store', 'school'},
        IncidentSeverity.high),
    TypeRule('vehicle_fire',
        {'car', 'vehicle', 'motorcycle', 'tricycle', 'jeepney', 'bus'},
        IncidentSeverity.moderate),
    TypeRule('electrical_fire',
        {'wire', 'wiring', 'outlet', 'electrical', 'transformer', 'sparks', 'short'},
        IncidentSeverity.high),
    TypeRule('grass_fire',
        {'grass', 'field', 'vacant', 'lot', 'bush'},
        IncidentSeverity.low),
  ],
  IncidentCategory.medical: [
    TypeRule('cardiac',
        {'chest', 'heart', 'attack', 'cardiac', 'stroke'},
        IncidentSeverity.critical),
    TypeRule('respiratory',
        {'breathing', 'asthma', 'choking', 'cannot', 'breathe'},
        IncidentSeverity.high),
    TypeRule('trauma',
        {'fall', 'fell', 'cut', 'wound', 'broken', 'fracture', 'bleeding'},
        IncidentSeverity.high),
    TypeRule('illness',
        {'fever', 'vomit', 'dizzy', 'sick', 'flu', 'pain'},
        IncidentSeverity.moderate),
  ],
  IncidentCategory.crime: [
    TypeRule('robbery',
        {'rob', 'robbery', 'snatch', 'snatcher', 'hold-up', 'armed'},
        IncidentSeverity.high),
    TypeRule('assault',
        {'assault', 'attack', 'fight', 'beat', 'stab', 'mauling'},
        IncidentSeverity.high),
    TypeRule('theft',
        {'theft', 'stolen', 'missing', 'shoplift', 'pickpocket', 'burglar'},
        IncidentSeverity.moderate),
    TypeRule('domestic',
        {'domestic', 'spouse', 'husband', 'wife', 'family', 'argument'},
        IncidentSeverity.moderate),
    TypeRule('vandalism',
        {'vandal', 'graffiti', 'broken', 'damaged'},
        IncidentSeverity.low),
  ],
  IncidentCategory.flood: [
    TypeRule('flash_flood',
        {'flash', 'sudden', 'rising', 'fast', 'overflow'},
        IncidentSeverity.high),
    TypeRule('street_flood',
        {'street', 'road', 'avenue', 'highway', 'knee', 'waist'},
        IncidentSeverity.moderate),
    TypeRule('drainage',
        {'drainage', 'canal', 'estero', 'clogged', 'blocked'},
        IncidentSeverity.low),
  ],
  IncidentCategory.accident: [
    TypeRule('vehicular_collision',
        {'car', 'truck', 'motorcycle', 'tricycle', 'collide', 'collision', 'crash', 'rammed'},
        IncidentSeverity.high),
    TypeRule('pedestrian',
        {'pedestrian', 'hit-and-run', 'sidewalk', 'crossing'},
        IncidentSeverity.high),
    TypeRule('workplace',
        {'construction', 'site', 'fall', 'machine', 'equipment'},
        IncidentSeverity.moderate),
    TypeRule('slip_fall',
        {'slip', 'tripped', 'stairs'},
        IncidentSeverity.low),
  ],
  IncidentCategory.other: [
    TypeRule('public_disturbance',
        {'noise', 'loud', 'party', 'disturbance'},
        IncidentSeverity.low),
    TypeRule('utility',
        {'power', 'outage', 'water', 'leak', 'gas'},
        IncidentSeverity.moderate),
    TypeRule('animal',
        {'animal', 'dog', 'snake', 'stray', 'rabid'},
        IncidentSeverity.moderate),
  ],
};

const Set<String> kEscalationTokens = {
  'trapped',
  'unconscious',
  'bleeding',
  'dead',
  'dying',
  'gunshot',
  'gun',
  'knife',
  'explosion',
  'collapse',
  'collapsed',
  'child',
  'children',
  'infant',
  'baby',
  'elderly',
  'multiple',
  'many',
  'several',
  'crowd',
};

const Set<String> kEscalationBigrams = {
  'fire spreading',
  'out of control',
  'not breathing',
  'no pulse',
  'cannot breathe',
  'getting worse',
};

const Set<String> kDeescalationTokens = {
  'minor',
  'small',
  'controlled',
  'extinguished',
  'resolved',
};

const Set<String> kDeescalationBigrams = {
  'false alarm',
  'no injury',
  'no injuries',
};
