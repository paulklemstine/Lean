# Computational evidence — S₅ / A₅ quintic type channel

All numbers below were produced inside the Lean project (`#eval` against the same
definitions that the theorems use), and every structural claim they support is proved in
`Catalog/MachineLearning/QuinticTypeChannelS5A5.lean` and
`Catalog/MachineLearning/QuinticTypeChannelS5A5Cap.lean` with no `sorry`.

## 1. Which quintic realises which group

For a depressed quintic `x⁵ + a x + b` the discriminant is `256 a⁵ + 3125 b⁴`.

| polynomial | `disc` | square? | consequence |
|---|---|---|---|
| `x⁵ − x − 1` | `2869 = 19 · 151` | no (`53² = 2809 ≠ 2869`) | Galois group ⊄ A₅ — the `S₅` endpoint |
| `x⁵ + 20x + 16` | `1024000000 = 32000²` | yes | Galois group ⊆ A₅ — the `A₅` endpoint |

(`#eval (256 * (-1:Int)^5 + 3125 * (-1:Int)^4, 256 * (20:Int)^5 + 3125 * (16:Int)^4)`
returns `(2869, 1024000000)`; `Nat.sqrt 1024000000` squares back to `1024000000`, while
`Nat.sqrt 2869` squares to `2809`.)

This confirms the round-24 ledger entry #2: the discriminant of `x⁵ − x − 1` is `2869`, not
the quartic's `−283`.  The square/non-square dichotomy is exactly the sign dial of the two
files: `signDial` is the quadratic character of the discriminant.

## 2. Chebotarev class sizes (the type histogram)

`#eval` over the 120 permutations of the five roots, grouped by cycle type:

```
S₅ : {(⟨⟩,1), ({2},10), ({2,2},15), ({3},20), ({3,2},20), ({4},30), ({5},24)}
A₅ : {(⟨⟩,1), ({2,2},15), ({3},20), ({5},24)}
```

Seven types for `S₅`, four for `A₅` — the odd types `{2}` (= `[1,1,1,2]`), `{3,2}`
(= `[2,3]`) and `{4}` (= `[1,4]`) never occur in `A₅`.  These histograms are the content of
`S5_class_sizes`, `A5_class_sizes`, `S5_image_qType`, `A5_image_qType` (all proved by kernel
evaluation, i.e. exact counting, not sampling).

## 3. The entropies

From the class sizes:

| object | closed form | value |
|---|---|---|
| `H(T)` for `S₅` | `7/5 + (17/40) log₂ 3 + (5/24) log₂ 5` | `2.557344…` |
| `H(T)` for `A₅` | `2/15 + (7/20) log₂ 3 + (5/12) log₂ 5` | `1.655540…` |
| `H(T)` for `F₂₀` (catalog) | `11/10 + (log₂ 5)/4` | `1.680482…` |
| `H(sign)` for `S₅` | `1` | `1` |
| `H(T ∣ sign)` for `S₅` | `2/5 + (17/40) log₂ 3 + (5/24) log₂ 5` | `1.557344…` |

The `A₅` figure reproduces the reported `1.6555`.  The `S₅` figure is `2.55734…`; the
round-24 report quotes `2.5574`, which differs from the exact value in the last quoted digit
(`2.557344` rounds to `2.5573`).  The certified brackets in the Lean files are
`2.5573 < H < 2.5574` and `1.6555 < H < 1.6556`, derived from the rational log bounds
`1054/665 < log₂ 3 < 485/306` and `339/146 < log₂ 5 < 1493/643` (each certified by an exact
integer power inequality such as `2^1054 < 3^665`).

## 4. Counterexample hunt on the two headline claims

* *Is the sign really a function of the factorisation type?*
  `#eval decide (∀ σ τ : Perm (Fin 5), σ.cycleType = τ.cycleType → sign σ = sign τ)`
  returns `true` — exhaustive over all 120² pairs.  No counterexample exists; the proved
  version `signDial_of_qType` derives it from `Perm.sign_of_cycleType` rather than from the
  enumeration.
* *Could some cleverer abelian dial beat one bit on `S₅`?*  No: `S5_abelian_dial_dichotomy`
  proves that **every** homomorphism of `S₅` into an abelian group gives exactly `1` bit (if
  nontrivial) or `0`, and `abelianization_cap` bounds the same quantity by `log₂ |G^ab|` for
  an arbitrary finite group.  A search is unnecessary because the statement is universally
  quantified and proved.
* *Could some residue direction hear the `A₅` type?*  No: `A5_seal` and
  `alternating_seal_of_cap` give the exact zero for every multiplicative dial and every
  read-out, so the reported "worst |z| = 1.72 over m ∈ {3,7,11,31}" is not a finite sample of
  a small effect but a sample of an identically zero channel.

## 5. What the evidence does *not* establish

The model is the Chebotarev box (uniform Frobenius), so the Lean theorems are statements
about the group-theoretic limit, not about any finite prime count.  Convergence rates,
plug-in bias of empirical mutual information (the reported `+0.2188` at a 2868-class dial)
and permutation nulls are statistical phenomena outside the formalised content; the exact
law values proved here (`1`, `0`, `1` for the pair channel) are precisely the reference
points those estimates are compared against.

## 6. Cycles 3–4: the general statements need no further evidence

The later files replace the degree-five computations by universally quantified theorems, so
there is nothing left to sample:

* `symmetric_one_bit_law` proves `I(sign ; cycleType) = 1` for permutations of *any* finite
  set, and `quintic_one_bit_law_of_tower` recovers the `Fin 5` case from it;
* `hom_dial_exact_law` gives `I(φ ; T) = log₂ |image φ|` for any finite group whenever the
  type refines the dial, and `uEnt_hom_eq_logb_image` shows a homomorphic dial always
  saturates the maximum-entropy bound;
* `product_channel_no_bonus` shows the `k`-fold (almost-prime) dial transmits exactly the
  single-prime amount for every `k ≥ 1`, so the reported semiprime pair figures (`1.0648`
  against the law's `1` at `S₅`, `0.0004` against `0` at `A₅`) are compared against proved
  reference values rather than simulated ones.

The only finite verification these files use is `image_sign_card_five` (`|image sign| = 2` on
`Perm (Fin 5)`), proved by exhaustive kernel evaluation.
