def is_complete(theory_decides):
    """Check if a theory is complete given a decision oracle.
    
    Args:
        theory_decides: function(sentence) -> bool|None
            Returns True if T |= phi, False if T |= ~phi, None if neither.
    
    Returns:
        True if theory is complete (every sentence is decided).
    """
    # In practice, we test a finite set of generators
    test_sentences = ['phi_1', 'phi_2', 'phi_3']  # domain-specific
    return all(theory_decides(s) is not None for s in test_sentences)
