def is_even_form(gram: list[list[int]]) -> bool:
    """A symmetric integral form is even iff every diagonal entry is even.
    O(n) check, justified by isEven_of_even_diag and its converse."""
    return all(gram[i][i] % 2 == 0 for i in range(len(gram)))
