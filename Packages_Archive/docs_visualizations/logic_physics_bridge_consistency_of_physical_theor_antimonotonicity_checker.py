def check_antimonotonicity(theory_chain, provable_chain, falsum=0):
    """Verify anti-monotonicity: if T_i is inconsistent, all T_j (j>=i) must be too."""
    found_inconsistent = False
    for i, (theory, provable) in enumerate(zip(theory_chain, provable_chain)):
        consistent = not provable(falsum)
        if found_inconsistent and consistent:
            return False, f"Violation at T_{i}: regained consistency"
        if not consistent:
            found_inconsistent = True
    return True, "Anti-monotonicity holds"

# Example
theories = [set(), {1}, {1,2}, {1,2,3}]
provables = [lambda s: False, lambda s: s==1, lambda s: s in {1,2}, lambda s: True]
ok, msg = check_antimonotonicity(theories, provables)
print(f"{ok}: {msg}")