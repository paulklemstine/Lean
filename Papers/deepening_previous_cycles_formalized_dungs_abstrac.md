# Computational Evidence — Argumentation IX

Small finite argumentation frameworks `(A, R)` were enumerated by hand to sanity-
check every claim before formalization.

## 1. Fundamental Lemma witnesses

- **Two mutual attackers** `A = {a, b}`, `R = {(a,b),(b,a)}`. `S = {a}` is
  admissible and defends `a`; `insert a S = {a}` is admissible. `S = ∅` defends
  nothing here (each argument's attacker is not counter-attacked), consistent
  with the grounded extension being `∅`.
- **Defense chain** `A = {a, b, c}`, `R = {(a,b),(b,c)}`. `S = {a}` is admissible
  and defends `c` (its only attacker `b` is attacked by `a`). Fundamental Lemma
  predicts `{a, c}` admissible — verified: conflict-free and each member defended.

## 2. Preferred = maximal complete

- **Empty attack relation** on `A = {a, b}`: the unique complete extension is the
  whole set `{a,b}`, which is also the unique preferred and stable extension.
  Matches `preferred_iff_maximal_complete`.
- **Two mutual attackers**: complete extensions are `∅` (grounded), `{a}`, `{b}`.
  Maximal complete = `{a}`, `{b}` = the preferred extensions = the stable
  extensions. The grounded `∅` is the least element. Confirms the pointed-poset
  picture.
- **Three-cycle** `R = {(a,b),(b,c),(c,a)}`: the only complete extension is `∅`,
  which is therefore simultaneously grounded and preferred, and there is **no**
  stable extension — confirming that `stable ⇒ preferred` is a strict one-way
  implication.

## 3. Existence of preferred extensions

Across all enumerated frameworks (including the odd cycle with no stable
extension) a preferred extension always exists, matching `exists_preferred`. The
empty set is admissible in every case and Zorn lifts it to a maximal admissible
set.

## 4. OEIS

The count of complete extensions is framework-specific and not a single integer
sequence; no OEIS lookup applies. No counterexample to any formalized statement
was found in the enumeration.
