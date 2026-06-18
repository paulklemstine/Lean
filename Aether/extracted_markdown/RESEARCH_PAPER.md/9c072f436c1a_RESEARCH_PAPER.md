# Set-Local Distortion of Hausdorff Dimension: Lipschitz, Antilipschitz, and Hölder Estimates on Subsets

## Abstract

The behavior of Hausdorff dimension under maps of bounded distortion is a
cornerstone of geometric measure theory and fractal geometry. The classical results
are *global*: isometries preserve dimension; Lipschitz maps do not increase it;
antilipschitz maps do not decrease it; bi-Lipschitz maps preserve it exactly. Yet the
objects of fractal geometry — attractors of iterated function systems, images under
quasi-symmetric homeomorphisms, self-similar sets — are typically controlled only on
the relevant subset, not on the whole ambient space. We develop the *set-local*
theory of dimension distortion. We prove that a Lipschitz left inverse on the image
forces a lower dimension bound (`dimH s ≤ dimH(f''s)`); we deduce set-local
bi-Lipschitz invariance (`dimH(f''s) = dimH s`); we establish a two-sided Hölder
squeeze `dimH(f''s) ≤ dimH s / r_f` and `dimH s ≤ dimH(f''s) / r_g` that
interpolates between the Lipschitz and general Hölder regimes; and we introduce a new
set-local predicate `AntilipschitzOnWith`, proving that it implies injectivity on the
set, yields a canonical Lipschitz inverse on the image, and gives the set-local lower
bound `dimH s ≤ dimH(f''s)`, culminating in an intrinsic bi-Lipschitz invariance
theorem. These are exactly the foundational tools demanded by the fractal-topology
research programme: the `AntilipschitzOnWith` infrastructure and the Hölder/
antilipschitz distortion estimates that underpin IFS dimension formulas, conformal
dimension, and quasi-symmetric rigidity.

**Keywords:** Hausdorff dimension, Lipschitz maps, antilipschitz maps, Hölder
continuity, bi-Lipschitz invariance, fractal geometry, quasi-symmetric maps,
conformal dimension, iterated function systems.

**MSC 2020:** 28A78 (Hausdorff and packing measures), 28A80 (Fractals), 30L10
(Quasiconformal mappings in metric spaces), 54E40 (Special maps on metric spaces).

---

## 1. Introduction

### 1.1 The problem

Let `(X, d_X)` and `(Y, d_Y)` be metric spaces and `f : X → Y` a map. The Hausdorff
dimension `dimH S` of a set `S ⊆ X` is the critical exponent

```
dimH S = inf { s ≥ 0 : μ_H^s(S) = 0 } = sup { s ≥ 0 : μ_H^s(S) = ∞ },
```

where `μ_H^s` denotes `s`-dimensional Hausdorff measure. Two facts are classical and
foundational:

- **(L)** If `f` is `K`-Lipschitz, i.e. `d_Y(f(x), f(y)) ≤ K·d_X(x, y)`, then
  `dimH(f(S)) ≤ dimH S`.
- **(A)** If `f` is `K`-antilipschitz, i.e. `d_X(x, y) ≤ K·d_Y(f(x), f(y))`, then
  `dimH S ≤ dimH(f(S))`.

Combining (L) and (A) gives bi-Lipschitz invariance: a bi-Lipschitz `f` satisfies
`dimH(f(S)) = dimH S`. These statements, together with `Isometry.dimH_image` and the
preservation of dimension under continuous linear equivalences, constitute the
standard toolkit.

### 1.2 Why "global" is not enough

The classical statements (L) and (A) quantify over **all** pairs `x, y ∈ X`. In
practice this is far too strong a hypothesis. Consider:

- **IFS attractors.** The coding map `π : {1, …, n}^ℕ → K` onto a self-similar
  attractor is Hölder, and its useful inverse exists only on a subset dictated by the
  *open set condition*; nothing nice happens off that subset.
- **Quasi-symmetric maps.** These have distortion that varies with scale; they are
  bi-Lipschitz only when restricted to a fixed scale on a fixed piece.
- **Local charts of fractals.** Self-similar sets carry good coordinates only on
  cylinder sets, not globally.

In each case, one controls `f` only on a subset `s ⊆ X`, and one wants a conclusion
about `dimH(f''s)` (the image of `s`). The global theorems are inapplicable. A
**set-local** theory is required.

### 1.3 Contributions

We work over extended metric spaces (`EMetricSpace`), with `edist` valued in
`ℝ≥0∞ = [0, ∞]`, and constants in `ℝ≥0`. Our contributions, all formalized and
machine-checked, are:

1. **(Theorem 3.1)** A Lipschitz left inverse on the image forces a lower dimension
   bound: if `g` is Lipschitz on `f''s` with `g(f(x)) = x` for `x ∈ s`, then
   `dimH s ≤ dimH(f''s)`.
2. **(Theorem 4.1)** Set-local bi-Lipschitz invariance: if `f` is Lipschitz on `s`
   and admits a Lipschitz left inverse on `f''s`, then `dimH(f''s) = dimH s`.
3. **(Theorem 5.1)** A two-sided Hölder squeeze: if `f` is `r_f`-Hölder on `s` and
   admits an `r_g`-Hölder left inverse on `f''s` (with `r_f, r_g > 0`), then
   `dimH(f''s) ≤ dimH s / r_f` and `dimH s ≤ dimH(f''s) / r_g`.
4. **(Definition 6.1, Theorems 6.2–6.5)** The set-local predicate
   `AntilipschitzOnWith`, with: injectivity on `s` (6.2); a canonical Lipschitz
   inverse on `f''s` (6.3); the set-local lower bound `dimH s ≤ dimH(f''s)` (6.4);
   and the intrinsic bi-Lipschitz invariance `dimH(f''s) = dimH s` from simultaneous
   Lipschitz + antilipschitz control (6.5).

These mirror and extend Mathlib's global lemmas (`LipschitzWith.dimH_image_le`,
`AntilipschitzWith.le_dimH_image`, `Isometry.dimH_image`) into the set-local
category.

---

## 2. Preliminaries and notation

Throughout, `X` and `Y` are extended metric spaces. We write:

- `edist x y ∈ [0, ∞]` for the extended distance.
- `f '' s = { f(x) : x ∈ s }` for the image of a set.
- `dimH s ∈ [0, ∞]` for the Hausdorff dimension.
- `K, C, r ∈ ℝ≥0` for non-negative real constants.

**Set-local Lipschitz.** `LipschitzOnWith K f s` means
`edist (f x) (f y) ≤ K · edist x y` for all `x, y ∈ s`.

**Set-local Hölder.** `HolderOnWith C r f s` means
`edist (f x) (f y) ≤ C · (edist x y)^r` for all `x, y ∈ s`.

We rely on two background facts from the established theory of Hausdorff dimension on
metric spaces, both available for set-local maps:

- **(Fact L)** `LipschitzOnWith.dimH_image_le`: if `LipschitzOnWith K f s` then
  `dimH(f''s) ≤ dimH s`.
- **(Fact H)** `HolderOnWith.dimH_image_le`: if `HolderOnWith C r f s` with `r > 0`,
  then `dimH(f''s) ≤ dimH s / r`. (At `r = 1` this reduces to Fact L.)

The contribution of this paper is to assemble these one-sided, set-local upper bounds
into two-sided invariance and distortion statements via the device of a controlled
*left inverse*, and to introduce the antilipschitz machinery that produces such an
inverse canonically.

---

## 3. Lower bounds from a Lipschitz left inverse

The key structural observation is that a left inverse converts an *upper* bound on
the inverse into a *lower* bound on the image.

### Theorem 3.1 (`le_dimH_image_of_lipschitzOn_leftInverse`)

*Let `f : X → Y`, `g : Y → X`, `s ⊆ X`. Suppose `g` is Lipschitz on `f''s`
(`LipschitzOnWith K g (f''s)`) and `g(f(x)) = x` for all `x ∈ s`. Then*

```
dimH s ≤ dimH (f '' s).
```

**Proof.** The hypothesis `g(f(x)) = x` on `s` says precisely that `g` maps the image
`f''s` back onto `s`. Concretely, `g '' (f '' s) = s`:

- *(⊆)* Any element of `g''(f''s)` is `g(f(x))` for some `x ∈ s`, which equals `x ∈ s`.
- *(⊇)* Any `x ∈ s` equals `g(f(x))` with `f(x) ∈ f''s`, so `x ∈ g''(f''s)`.

Now apply Fact L to the Lipschitz map `g` on the set `f''s`:

```
dimH s = dimH (g '' (f '' s)) ≤ dimH (f '' s).        ∎
```

**Remark.** The theorem requires *no* hypothesis on `f` itself — not even continuity.
All the control is carried by the inverse `g`. This is what makes it the right
primitive: it isolates exactly the ingredient (a Lipschitz left inverse) that
manufactures a lower bound.

---

## 4. Set-local bi-Lipschitz invariance

### Theorem 4.1 (`dimH_image_eq_of_lipschitzOn_lipschitzOn_inverse`)

*Let `f : X → Y`, `g : Y → X`, `s ⊆ X`. Suppose `LipschitzOnWith K_f f s`,
`LipschitzOnWith K_g g (f''s)`, and `g(f(x)) = x` for all `x ∈ s`. Then*

```
dimH (f '' s) = dimH s.
```

**Proof.** Antisymmetry of `≤`:

- *Upper bound:* `dimH(f''s) ≤ dimH s` by Fact L applied to `f` on `s`.
- *Lower bound:* `dimH s ≤ dimH(f''s)` by Theorem 3.1 applied to the inverse `g`.   ∎

This is the set-local analogue of global bi-Lipschitz invariance. The crucial
strengthening over the classical statement is that **both Lipschitz hypotheses are
restricted to sets** — `f` to `s`, `g` to `f''s` — so the theorem applies to maps
that behave badly off the relevant piece.

---

## 5. Two-sided Hölder distortion

We now relax both Lipschitz hypotheses to Hölder, obtaining a *quantitative* squeeze
rather than exact invariance. This is the dimension-theoretic shadow of
quasi-symmetric distortion.

### Theorem 5.1 (`dimH_image_bounds_of_holderOn_holderOn_inverse`)

*Let `f : X → Y`, `g : Y → X`, `s ⊆ X`, with constants `C_f, C_g, r_f, r_g ∈ ℝ≥0`.
Suppose `HolderOnWith C_f r_f f s` with `r_f > 0`, `HolderOnWith C_g r_g g (f''s)`
with `r_g > 0`, and `g(f(x)) = x` for all `x ∈ s`. Then*

```
dimH (f '' s) ≤ dimH s / r_f      and      dimH s ≤ dimH (f '' s) / r_g.
```

**Proof.** As in Theorem 3.1, `g''(f''s) = s`. Then:

- *Forward bound:* Fact H applied to `f` on `s` gives `dimH(f''s) ≤ dimH s / r_f`.
- *Inverse bound:* Fact H applied to `g` on `f''s` gives
  `dimH s = dimH(g''(f''s)) ≤ dimH(f''s) / r_g`.                                     ∎

**Interpretation.** Setting `r_f = r_g = 1` recovers Theorem 4.1 exactly: the squeeze
collapses to `dimH(f''s) = dimH s`. For `r_f, r_g < 1` the two inequalities bound how
far the dimension may drift, with the drift factor governed by the Hölder exponents.
Combining them:

```
r_g · dimH s ≤ dimH (f '' s) ≤ dimH s / r_f          (when r_f ≤ 1).
```

This is precisely the form one needs when feeding in the coding map of an IFS
attractor, whose Hölder exponents are determined by the contraction ratios (see §7).

**On the false naïve guess.** One might hope that *every* "reasonable" map can only
decrease dimension. The Hölder squeeze shows this is false in a controlled way:
genuine dimension change is possible and is bounded by the exponents `r_f, r_g`. This
controlled change is the entire reason conformal dimension (§7.2) is a nontrivial
invariant.

---

## 6. The set-local antilipschitz predicate

Theorems 3.1, 4.1, and 5.1 all require the user to *supply* a left inverse `g`. We
now show that an intrinsic condition on `f` alone manufactures the inverse
automatically. This is the conceptual heart of the development.

### Definition 6.1 (`AntilipschitzOnWith`)

*For `K ∈ ℝ≥0`, `f : X → Y`, `s ⊆ X`, define*

```
AntilipschitzOnWith K f s  :⟺  ∀ x ∈ s, ∀ y ∈ s,  edist x y ≤ K · edist (f x) (f y).
```

This is the set-local analogue of Mathlib's global `AntilipschitzWith`: `f` does not
contract distances within `s` by more than the factor `K`.

### Theorem 6.2 (`AntilipschitzOnWith.injOn`)

*If `AntilipschitzOnWith K f s` then `f` is injective on `s`.*

**Proof.** Suppose `x, y ∈ s` with `f(x) = f(y)`. The defining inequality gives
`edist x y ≤ K · edist (f x) (f y) = K · 0 = 0`, hence `x = y`.                       ∎

Injectivity on `s` is what makes a well-defined inverse possible. We use the canonical
left inverse `invFunOn f s`, which on `f''s` selects the (unique, by injectivity)
preimage in `s`.

### Theorem 6.3 (`AntilipschitzOnWith.lipschitzOnWith_invFunOn`)

*Assume `X` nonempty. If `AntilipschitzOnWith K f s`, then the canonical left inverse
`invFunOn f s` is Lipschitz on the image:*

```
LipschitzOnWith K (invFunOn f s) (f '' s).
```

**Proof.** Take two points of `f''s`, say `f(x)` and `f(y)` with `x, y ∈ s`. By
injectivity (Theorem 6.2) and the left-inverse property of `invFunOn`,
`invFunOn f s (f x) = x` and `invFunOn f s (f y) = y`. Thus the required Lipschitz
inequality

```
edist (invFunOn f s (f x)) (invFunOn f s (f y)) = edist x y ≤ K · edist (f x) (f y)
```

is exactly the antilipschitz hypothesis.                                              ∎

### Theorem 6.4 (`AntilipschitzOnWith.le_dimH_image`)

*Assume `X` nonempty. If `AntilipschitzOnWith K f s`, then*

```
dimH s ≤ dimH (f '' s).
```

**Proof.** Apply Theorem 3.1 with `g = invFunOn f s`. Its Lipschitz property on `f''s`
is Theorem 6.3, and its left-inverse property `g(f(x)) = x` on `s` follows from
injectivity. The conclusion is the set-local antilipschitz lower bound.              ∎

This is the set-local analogue of Mathlib's `AntilipschitzWith.le_dimH_image`,
proved without supplying an external inverse.

### Theorem 6.5 (`dimH_image_eq_of_lipschitzOn_antilipschitzOn`)

*Assume `X` nonempty. If `LipschitzOnWith K_f f s` and `AntilipschitzOnWith K_f' f s`,
then*

```
dimH (f '' s) = dimH s.
```

**Proof.** Upper bound from Fact L (Lipschitz); lower bound from Theorem 6.4
(antilipschitz); combine by antisymmetry.                                            ∎

This is the cleanest, intrinsic form of set-local bi-Lipschitz invariance: a single
map, two local conditions, no external inverse. As a sanity check, the identity map on
any subset is both `1`-Lipschitz and `1`-antilipschitz, recovering the trivial
`dimH(id''s) = dimH s`.

---

## 7. Applications

### 7.1 Dimension of IFS attractors via the coding map

Let `{f_1, …, f_n}` be contractions on a complete metric space with ratios
`r_1, …, r_n ∈ (0,1)`, and let `K` be their attractor (the unique nonempty compact
set with `K = ⋃_i f_i(K)`). The *similarity dimension* `s` solves `Σ_i r_i^s = 1`.

The standard route to `dimH K = s` uses the coding map `π : Σ = {1,…,n}^ℕ → K`,
`π(ω) = lim_{m} f_{ω_1} ∘ ⋯ ∘ f_{ω_m}(x_0)`, equipped with the metric
`d_Σ(ω, ω') = ratio^{first disagreement}`. One checks:

- `π` is **Hölder** with exponent depending on the contraction ratios, so by Fact H,
  `dimH K ≤ dimH(π''Σ) / (\text{exponent})`.
- Under the **open set condition**, `π` admits a Hölder/antilipschitz inverse on a
  large subset, supplying the reverse bound through Theorem 5.1.

Plugging both into the two-sided Hölder squeeze (Theorem 5.1) pins `dimH K` between
multiples of `dimH Σ`, and since `dimH Σ` is computed directly from the symbolic
metric, one recovers `dimH K = s`. The set-local nature is essential: the inverse of
`π` exists only on the subset cut out by the open set condition.

### 7.2 Conformal dimension

The *conformal dimension* of a metric space `X` is

```
cdim(X) = inf { dimH Y : Y is quasi-symmetrically equivalent to X }.
```

It is invariant under quasi-symmetric homeomorphisms and satisfies `cdim(X) ≤ dimH X`.
Theorem 6.5 (`dimH_image_eq_of_lipschitzOn_antilipschitzOn`) is precisely the
*bi-Lipschitz special case* (linear distortion modulus) of the invariance underlying
conformal dimension. Conceptually, `cdim` is "what remains after quotienting the
bi-Lipschitz invariance by the coarser quasi-symmetric equivalence." The set-local
machinery here certifies the bi-Lipschitz layer on arbitrary subsets, the natural
launchpad for the quasi-symmetric theory.

### 7.3 Quasi-symmetric distortion bounds

A map is `η`-quasi-symmetric if `edist(f x, f a)/edist(f x, f b) ≤ η(edist(x,a)/edist(x,b))`.
At each fixed scale, such a map is bi-Hölder with exponents determined by
`log η(t)/log t`. Decomposing `s` into a countable union of scale pieces and applying
Theorem 5.1 on each, then gluing via countable stability of Hausdorff dimension,
yields distortion bounds of the form
`dimH(f''s) ≤ (limsup_{t→0} log η(t)/log t) · dimH s`. The two-sided Hölder squeeze on
arbitrary subsets is exactly the per-scale input this argument consumes.

---

## 8. Discussion

### 8.1 The role of the left inverse

The unifying device throughout is the *left inverse*. Upper bounds (Facts L, H) are
"free" — they follow from contraction control on the forward map. The difficulty is
always the *lower* bound, which requires preventing collapse. Theorem 3.1 shows the
cleanest way to obtain a lower bound is to exhibit a controlled left inverse; the
antilipschitz predicate (Definition 6.1) is the intrinsic hypothesis that produces one
canonically. This factorization — "upper from forward, lower from inverse" — keeps
each proof a one-line composition of a background lemma with the set identity
`g''(f''s) = s`.

### 8.2 Why extended metric spaces

Working over `EMetricSpace` with `edist ∈ [0,∞]` and `dimH ∈ [0,∞]` is not pedantry:
fractal constructions naturally produce infinite distances and infinite-dimensional
limits, and the division `dimH s / r` in Theorem 5.1 lives in the extended
non-negative reals, where `x/0 = ∞` and `∞/r = ∞` behave correctly. The formal
development takes place entirely in this setting, so the theorems apply without
side-conditions ruling out degenerate cases.

### 8.3 Relation to the global theory

| Global (classical)                  | Set-local (this paper)                                   |
|-------------------------------------|----------------------------------------------------------|
| `LipschitzWith.dimH_image_le`       | Fact L (`LipschitzOnWith.dimH_image_le`)                 |
| `AntilipschitzWith.le_dimH_image`   | Theorem 6.4 (`AntilipschitzOnWith.le_dimH_image`)        |
| bi-Lipschitz ⇒ dimension invariant  | Theorems 4.1, 6.5                                         |
| Hölder one-sided bound              | Theorem 5.1 (two-sided squeeze)                          |
| `AntilipschitzWith` (predicate)     | Definition 6.1 (`AntilipschitzOnWith`)                   |

Each set-local statement specializes to its global counterpart by taking `s` to be the
whole space. The converse direction — deducing set-local results from global ones — is
*not* available in general, since a map controlled only on `s` need not extend to a
globally controlled map. This is the precise sense in which the set-local theory is a
genuine strengthening.

---

## 9. Future work

1. **Quasi-symmetric distortion governed by the modulus η.** Replace the single
   Hölder exponent by a scale-dependent modulus and bound `dimH(f''s)` by the
   asymptotics of `η` near `0` and `∞`, via a countable scale decomposition feeding
   Theorem 5.1. Caution: the naïve `dimH(f''s) ≤ dimH s` is *false* for general
   quasi-symmetric maps.

2. **Conformal dimension as a quasi-symmetric invariant.** Build the quasi-symmetric
   equivalence relation, prove `cdim` invariance and `cdim(X) ≤ dimH X`, with Theorem
   6.5 as the bi-Lipschitz anchor.

3. **IFS attractor dimension via the coding map's Hölder section.** Formalize §7.1 in
   full: the Hölder coding map, the open-set-condition antilipschitz section, and the
   resulting `dimH K = s`.

4. **Product sets.** Prove `dimH(A × B) ≥ dimH A + dimH B`, using the projection maps
   and the Lipschitz-inverse technique.

5. **Bi-Lipschitz embedding dimension.** Define `bldim(X) = inf{ n : X` bi-Lipschitz
   embeds in `ℝ^n }` and derive `bldim(X) ≥ ⌈dimH X⌉` for free from set-local
   bi-Lipschitz invariance (Theorem 6.5) and `dimH ℝ^n = n`.

---

## 10. Conclusion

We have rebuilt the theory of Hausdorff-dimension distortion in the set-local
category, where control is demanded only on the subset that matters. The four pillars
— the Lipschitz-inverse lower bound (3.1), set-local bi-Lipschitz invariance (4.1),
the two-sided Hölder squeeze (5.1), and the `AntilipschitzOnWith` infrastructure
(6.1–6.5) — supply exactly the foundational tools that IFS dimension formulas,
conformal dimension, and quasi-symmetric rigidity have been waiting for. The
unifying idea is simple and robust: upper bounds come from the forward map, lower
bounds come from a controlled inverse, and the antilipschitz condition manufactures
that inverse for free. Localizing these classical theorems is precisely what lets them
meet the rough, partial, scale-dependent maps of real fractal geometry on their own
terms.
