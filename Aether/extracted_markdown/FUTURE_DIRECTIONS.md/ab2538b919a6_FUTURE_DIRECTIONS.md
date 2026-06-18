# Future Directions: EML Depth Separation Theory

## Conjecture 1: Full Growth Bound Theorem (inv case)

**Conjecture:** For every EMLExpr `e` (including those with `inv` nodes), if `e.emlDepth ≤ D`, then there exist `C > 0` and `X` such that for all `x ≥ X`, `|e.eval x| ≤ iterExp (D + 1) (C * x)`.

**Test:** Formalize the growth bound for expressions with `inv` by showing that rational functions (built from `+`, `*`, `neg`, `inv` applied to `x` and constants) have polynomial growth, and that `eml` layers add exactly one exponential level regardless of `inv` presence. The key step is proving that `inv` preserves eventual polynomial growth for no-eml subexpressions.

**Impact:** This would extend the depth separation from inv-free to all EMLExpr, giving the fully general theorem: no bounded-depth EMLExpr can represent `iterExp n` for large `n`.

---

## Conjecture 2: Tight Depth Bound (D+1 instead of D+3)

**Conjecture:** For every `D ≥ 0` and `n > D`, no inv-free EMLExpr of `emlDepth ≤ D` can represent `iterExp n` on positive reals.

Currently we prove separation for `n ≥ D + 3` due to slack in the growth comparison. The gap of 2 comes from the interplay between growth bound level (D+1) and the strict comparison chain (D+1 < D+2 < D+3).

**Test:** Improve the growth bound to `iterExp (D + 1) (C * x)` → show `iterExp n x > iterExp (D + 1) (C * x)` directly for `n ≥ D + 2`, eliminating one level. Alternatively, prove the tight bound `n > D` by a direct structural induction argument that avoids the growth bound entirely.

**Impact:** The tight bound would show that `emlExprIterExp n` with `emlDepth = n` is essentially optimal: no representation with fewer eml layers exists.

---

## Conjecture 3: Exponential Size Lower Bound

**Conjecture:** For fixed depth `D`, the minimal size of an EMLExpr of depth ≤ D that represents `iterExp n` on a finite grid of positive reals grows exponentially in `n` (for `n ≤ D`).

**Test:** For `D = 5` and `n ∈ {1, ..., 5}`, enumerate all EMLExpr of depth ≤ D up to size 100. Evaluate each on a grid of 20 positive points. Record the minimal size that matches `iterExp n`. Plot size vs `n` and fit exponential vs polynomial models. A polynomial fit with R² > 0.99 would refute the conjecture.

**Impact:** This would provide quantitative lower bounds beyond the qualitative depth separation, analogous to exponential size lower bounds for bounded-depth Boolean circuits computing specific functions.

---

## Conjecture 4: Depth Hierarchy for Trigonometric Extensions

**Conjecture:** If the EML language is extended with a `trig(a,b) = a * sin(b)` primitive, the resulting "EML+Trig" language still cannot represent `iterExp n` at bounded depth, and furthermore the trig primitive does not help compress iterated exponentials.

**Test:** Define `EMLTrigExpr` with both `eml` and `trig` constructors. Extend the growth bound theorem to show that `trig` nodes do not increase the exponential nesting level (since `|sin(t)| ≤ 1`). Prove that the depth separation still holds in the extended language.

**Impact:** This would show that the depth hierarchy is robust under natural extensions of the expression language, strengthening the claim that it captures a fundamental structural property of iterated exponentials rather than an artifact of the EML formalism.

---

## Conjecture 5: Connection to Hardy Field Hierarchy

**Conjecture:** The `growthRank` invariant defined in our framework is equivalent to the level in the Hardy field hierarchy for germs of functions definable by EML expressions.

More precisely: an EML expression of `emlDepth ≤ D` defines a germ in the Hardy field `\mathcal{H}_D` (the D-th level of the log-exp hierarchy), and `iterExp n` lies in `\mathcal{H}_n \setminus \mathcal{H}_{n-1}`.

**Test:** Formalize the connection between `emlDepth` and Hardy field levels. The key step is showing that `eml(a,b) = a * exp(b)` maps `\mathcal{H}_D × \mathcal{H}_D → \mathcal{H}_{D+1}`. If this can be formalized, the depth separation would follow from the known strict hierarchy of Hardy fields.

**Impact:** This would connect our mechanized complexity theory to a rich body of classical analysis (Hardy, Bourbaki, Rosenlicht, Boshernitzan), providing both a conceptual foundation and access to deep existing results. It would also suggest that the depth hierarchy extends to much broader classes of "tame" functions.
