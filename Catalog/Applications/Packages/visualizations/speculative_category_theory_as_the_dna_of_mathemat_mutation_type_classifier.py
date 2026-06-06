def classify_mutation(unit_is_iso: bool, counit_is_iso: bool) -> str:
    if unit_is_iso and counit_is_iso: return 'equivalence'
    elif counit_is_iso: return 'reflective'
    elif unit_is_iso: return 'coreflective'
    else: return 'general'