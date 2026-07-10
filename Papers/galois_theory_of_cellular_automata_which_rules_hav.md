# Computational Evidence

Framework: binary cellular automata (CAs) on the finite cyclic lattice `ℤ/n`.
A configuration is a map `ℤ/n → Bool`. An elementary (radius-1) local rule is a
function `r : Bool³ → Bool` (Wolfram's 256 rules); its global map is
`(caMap r c) i = r (c (i-1), c i, c (i+1))`. The CA is **reversible** on that
lattice when the global map is a bijection.

## 1. Counting

* Local rules: `|Bool^(Bool³)| = 2^8 = 256`.  (Formalized: `card_rules`.)
* Neighbourhoods: `|Bool³| = 8`.               (Formalized: `card_neighborhoods`.)

## 2. Which of the 256 rules are reversible on every cyclic lattice?

Enumerating the 256 rules and testing bijectivity of the global map on
`ℤ/n` for `n = 2,3,4,5,6` (brute force over all `2^n` configurations) gives, as
the rules reversible for **all** these `n`, exactly the six rules highlighted in
the mission statement:

| Rule | binary  | local rule (l,c,r) ↦ | global map            |
|-----:|:--------|:---------------------|:----------------------|
|  204 | 11001100| c                    | identity              |
|   51 | 00110011| ¬c                   | complement            |
|  170 | 10101010| r                    | left shift            |
|  240 | 11110000| l                    | right shift           |
|   15 | 00001111| ¬l                   | complement ∘ rightshift |
|   85 | 01010101| ¬r                   | complement ∘ leftshift  |

These are **exactly** the rules whose output depends on a single neighbour,
possibly negated — the "affine, single-site" rules. This matches the general
theory: reversible one-dimensional CAs with a one-sided memoryless inverse of the
same radius are precisely the ones built from shifts and the alphabet's
permutations. Each of the six global maps is proved bijective in Lean
(`rule204_bijective`, …, `rule85_bijective`).

Rules outside this list fail for small `n`. E.g. rule 0 (constant `false`) maps
every configuration to the all-`false` one, so it is not surjective for `n ≥ 1`
(formalized as `ruleConst_not_bijective`).

## 3. Sanity check on the mission's numerical conjecture (counterexample hunt)

The mission conjectures `|G(1,{0,1})| = 8!/4 = 10080` as "the permutations of the
8 neighbourhoods commuting with the shift". This is **false**:

* The natural order-3 rotation of the 3 cells acts on the 8 neighbourhoods with
  cycle type `1² · 3²` (fixed points `000, 111`; 3-cycles `{001,010,100}` and
  `{011,110,101}`). Its centraliser in `S₈` has order
  `(2!·1²)·(2!·3²) = 2·18 = 36`, not `10080`.
* Moreover reversible global CA maps are far more constrained than arbitrary
  permutations of neighbourhoods, so the intended object is not `S₈`-sized at all.

We therefore do **not** attempt to prove the false `10080` claim. Instead the
Lean development proves the genuine structural facts: translation invariance, the
identification and reversibility of the six distinguished rules, membership of the
shift and complement in the reversibility group (centraliser of the shift), the
orders of these generators, that they commute, and that the subgroup they
generate is abelian.

## 4. OEIS

No new integer sequence is central here; the relevant constants (`256`, `8`, the
six rule numbers `15, 51, 85, 170, 204, 240`) are fixed small data rather than a
growing sequence.
