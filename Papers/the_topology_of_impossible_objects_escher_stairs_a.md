# Computational Evidence — The Cohomology of Impossible Figures

All numbers below were computed in Lean (`#eval`) and match the formal theorems in
`Catalog/Novelty/ImpossibleFiguresCohomology.lean` and
`Catalog/Novelty/ImpossibleFiguresDevelopable.lean`.

## Model

A cyclic figure of `n` overlapping patches is a function `t : ZMod n → A`
(`A` an abelian group). Its holonomy / monodromy is the total increment around
the loop:

* additive:      `holonomy t = ∑ i, t i`     (depth / height / orientation)
* multiplicative: `monodromy t = ∏ i, t i`   (scaling ambiguity)

A figure is *realizable* (assemblable into a globally consistent object) iff this
class is trivial. The tables below exhibit the dichotomy on small cases.

## 1. Penrose triangle (additive depth, `A = ℝ`, uniform `+1`)

| n | data                | holonomy | realizable? |
|---|---------------------|----------|-------------|
| 3 | `(1,1,1)`           | **3**    | NO — impossible |
| 4 | `(1,1,1,1)`         | **4**    | NO — Escher stairs |

`#eval holonomy (n:=3) (fun _ => 1) = 3`, `#eval holonomy (n:=4) (fun _ => 1) = 4`.
Nonzero holonomy ⇒ no global depth field ⇒ the figure is impossible.
Formalized: `penrose_triangle_impossible`, `escher_staircase_impossible`.

## 2. Impossibility is global, not local (contrarian check)

| n | data          | holonomy | realizable? | local data |
|---|---------------|----------|-------------|------------|
| 3 | `(1,1,1)`     | 3        | NO          | perfectly **uniform** |
| 3 | `(1,2,-3)`    | **0**    | YES         | pairwise **distinct** |

`#eval holonomy (n:=3) (fun i => if i=0 then 1 else if i=1 then 2 else -3) = 0`.
So uniform data can be impossible while maximally non-uniform data is realizable:
the obstruction cannot be read off the local increments.
Formalized: `impossible_uniform`, `realizable_nonuniform`.

## 3. Non-orientability (orientation cocycle, `A = ZMod 2`)

Total holonomy in `ZMod 2` counts orientation flips mod 2.

| n | # flips | holonomy in ZMod 2 | orientable? |
|---|---------|--------------------|-------------|
| 3 | 3 (odd) | **1**              | NO — Möbius / Klein |
| 4 | 4 (even)| 0                  | YES |

`#eval (∑ i : ZMod 3, (1:ZMod 2)) = 1`, `#eval (∑ i : ZMod 4, (1:ZMod 2)) = 0`.
An odd number of flips ⇒ one-sided band, no global orientation.
Formalized: `klein_bottle_nonorientable`, `mobius_band_nonorientable`.

## 4. Multiplicative (Penrose's original scaling model)

Scaling ambiguities live in a multiplicative group; monodromy is the product.

| n | data (in ℚˣ-values) | monodromy | developable? |
|---|---------------------|-----------|--------------|
| 3 | `(2,2,2)`           | **8 = 2³**| NO |
| 2 | `(2, 1/2)`          | **1**     | YES (cancels) |

`#eval (∏ i : ZMod 3, (2:ℚ)) = 8`, `#eval (∏ i : ZMod 2, (if i=0 then 2 else 2⁻¹ : ℚ)) = 1`.
Every scaling in the second figure is nontrivial (`2 ≠ 1`, `1/2 ≠ 1`) yet it is
developable — again showing impossibility is global.
Formalized: `penrose_scaling_triangle_not_developable`,
`developable_with_nontrivial_scalings`.

## OEIS

The holonomy of the uniform `+1` figure on `n` patches is simply `n`
(OEIS A000027, the natural numbers) — the point being that it is *never* `0` for
`n ≥ 1`, which is exactly why a closed uniform staircase can never exist. No
deeper sequence is involved; the mathematics is structural (a `H¹` computation),
not enumerative.

## Counterexample hunt

The universal claims proved (`realizable_iff`, `mrealizable_iff`) were stress-tested
against the "local ⇒ global" fallacy: we searched for figures that are locally
irregular yet globally fine (`(1,2,-3)`, `(2,1/2)`) and locally regular yet
globally broken (`(1,1,1)`). Both directions occur, confirming the invariant is
genuinely the holonomy class and nothing coarser. No counterexample to the main
equivalences was found (and none can exist — they are theorems).
