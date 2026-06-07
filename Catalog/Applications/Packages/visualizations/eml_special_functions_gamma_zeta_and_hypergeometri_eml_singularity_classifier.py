def classify_singularity(stype):
    return {
        'removable': {'meromorphic': True, 'eml_compatible': True},
        'pole': {'meromorphic': True, 'eml_compatible': True},
        'logBranch': {'meromorphic': False, 'eml_compatible': True},
        'essential': {'meromorphic': False, 'eml_compatible': False}
    }[stype]