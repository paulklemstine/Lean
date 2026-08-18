# Computational Evidence — Almost-Lossless / Monte-Carlo Compression

*Exploratory numerics used to shape the conjectures before formalization.  These
are ad-hoc simulations, **not** verified computations; only the Lean files in
`Catalog/Bridges/AlmostLossless*.lean` are machine-checked.*

## 1. The first-moment bound `E_k[P(fail)] ≤ |S|/M`

Family: `h_{a,b}(x) = ((a·x + b) mod p) mod M` on `Z_p`, `p = 1009` (a standard
2-universal family), source uniform on a random typical set `S` with `|S| = 30`,
400 random keys per row, failure = "`x` shares its hash with another `S`-element".

| `M` | measured avg `P(fail)` | best key found | predicted bound `|S|/M` | silent errors on codebook |
|-----|------------------------|----------------|--------------------------|---------------------------|
| 32  | 0.5929 | 0.3333 | 0.9375 | 0 |
| 64  | 0.3611 | 0.0000 | 0.4688 | 0 |
| 128 | 0.1854 | 0.0000 | 0.2344 | 0 |
| 256 | 0.0805 | 0.0000 | 0.1172 | 0 |
| 512 | 0.0302 | 0.0000 | 0.0586 | 0 |

Observations that drove the formalization:

* the measured average is always below `|S|/M` and within a factor ≈ 2 of it, so
  the bound proved in `sum_collision_mass_le` is the right order and not
  improvable by more than a constant;
* the *best* key is far better than the average — the derandomized statement
  `exists_good_key` is therefore not wasteful;
* **zero** silent errors on codebook symbols in every run, for every key,
  including the badly-parameterised `M = 32` row.  This is what suggested that
  "no silent corruption on the codebook" is *unconditional* rather than
  probabilistic — it is proved as `decodeList_never_wrong_on_codebook`
  (the argument: `x` itself is always among the matches, so a unique match must
  be `x`).

## 2. Decoder cost: coordinatewise versus one-shot

Codebook size `n` per block, `b` blocks.  One-shot random coding scans the
product codebook (`n^b` entries); the block decoder scans `b·n`.

| `n` | `b` | block cost `b·n` | one-shot cost `n^b` | ratio |
|-----|-----|------------------|----------------------|-------|
| 2 | 3 | 6 | 8 | 1.33 |
| 2 | 10 | 20 | 1 024 | 51.2 |
| 4 | 5 | 20 | 1 024 | 51.2 |
| 4 | 10 | 40 | 1 048 576 | 2.6·10⁴ |
| 16 | 10 | 160 | 1.1·10¹² | 6.9·10⁹ |

The smallest case with a strict gap for `n = 2` is `b = 3` (6 < 8), which is
exactly the hypothesis range of the formal statement `linear_lt_pow`
(`2 ≤ n`, `3 ≤ b`).  For `b = 2, n = 2` one has `b·n = 4 = n^b`, so the strict
inequality genuinely needs `b ≥ 3`; this counterexample hunt fixed the
hypotheses of the theorem.

## 3. Counterexample hunt on the converse

For the relaxed pigeonhole bound we tested `P(success) ≤ |Code|·p_max` on 20 000
random instances (random distribution, random encoder, random partial decoder,
`2 ≤ |α| ≤ 8`, `1 ≤ |Code| ≤ 4`): **0 violations, 922 equality cases**.  Equality
occurs when the code space is used injectively on `|Code|` symbols all of
maximal probability.  This equality case is why the
converse is stated with `maxMass` (min-entropy) rather than with a cruder
`|Code|/|α|` factor.

---

# Cycle 2 evidence (sub-linear decoding, sharp silent errors, higher independence)

*Again ad-hoc simulations used to shape the conjectures; only the Lean files are
machine-checked.*

## 4. Sharp silent-error bound (Conjecture 2 → `exists_sharp_almost_lossless_scheme`)

Family `h_{a,b}(x) = ((a·x + b) mod 1009) mod M`, 200 random keys, codebook
`|S| = 30`, mass `δ` placed uniformly outside the codebook.

| `M` | `δ` | measured avg silent mass | sharp bound `2δ|S|/M` | old bound `|S|/M` |
|-----|-----|--------------------------|-----------------------|-------------------|
| 64  | 0.10 | 0.0358 | 0.0938 | 0.4688 |
| 128 | 0.10 | 0.0188 | 0.0469 | 0.2344 |
| 256 | 0.02 | 0.0017 | 0.0047 | 0.1172 |

The measured silent mass tracks `δ|S|/M`, i.e. it is smaller than the *failure*
mass by a factor `δ`, exactly as the sharpened theorem asserts; the old bound
`|S|/M` overestimates it by more than an order of magnitude.  This is what
motivated instantiating the free region `A` of `sum_collision_mass_le` at `Sᶜ`
and proving the two-sided derandomization `exists_doubly_good_key`.

## 5. Factorial moments beat Markov (Conjecture 3 → `exists_list_scheme_exponential`)

Fully random hash values (the `T`-wise independent extreme, formalized as
`fullFamily_indepT`), codebook `|S| = 30`, 20 000 trials per row.  "Markov" is
the bound `|S|/(T·M)` from 2-universality; "factorial" is the new bound
`C(|S|,T)/M^T`.

| `M` | `T` | empirical `P(≥T collisions)` | Markov `|S|/(TM)` | factorial `C(|S|,T)/M^T` |
|-----|-----|------------------------------|--------------------|---------------------------|
| 64  | 1 | 0.3748 | 0.4688 | 0.4688 |
| 64  | 2 | 0.0842 | 0.2344 | 0.1062 |
| 64  | 3 | 0.0112 | 0.1563 | 0.0155 |
| 64  | 4 | 0.0018 | 0.1172 | 0.0016 |
| 128 | 3 | 0.0019 | 0.0781 | 0.0019 |
| 256 | 4 | 0.0000 | 0.0293 | 0.000006 |

The Markov bound decays like `1/T`; the empirical failure probability and the
factorial bound both decay geometrically, and agree to within a few per cent
from `T = 2` on.  This ruled out "the linear gain is real" and pointed at the
`T`-th factorial moment as the right statistic.

## 6. Cost of the logarithmic decoder (Conjecture 1 → `exists_sublinear_almost_lossless_scheme`)

Deterministic figures for the two decoders on a codebook of `n` entries; the
binary-search column is the *proved* upper bound `⌊log₂ n⌋ + 3`
(`bsDecode_cost_le`), the scan column is the *proved exact* cost `n`
(`scanCost_snd`).

| `n` | scan cost | binary-search bound | speed-up |
|-----|-----------|---------------------|----------|
| 8    | 8    | 6  | 1.3× |
| 64   | 64   | 9  | 7.1× |
| 1000 | 1000 | 12 | 83× |
| 10⁶  | 10⁶  | 22 | 4.5·10⁴× |

The crossover is at `n = 6` (`⌊log₂ 6⌋ + 3 = 5 < 6`), which is exactly the
hypothesis of the formal separation `sublinear_speedup`.

---

## Cycle 3 — evidence for the conjectures settled in this cycle

These computations were run ad hoc (small brute-force enumerations in a scratch
script) *before* the Lean proofs, to check that the statements were true and
worth formalizing.  They are **not** machine-checked; only the Lean files are.

### 1. Higher independence of the degree-`T` polynomial family (Conjecture B)

For every prime `p` and degree `T` below, all pairs `(x, s)` with `|s| = T`,
`x ∉ s` were enumerated and the number of coefficient vectors
`c ∈ (ZMod p)^{T+1}` with `h_c(y) = h_c(x)` for all `y ∈ s` was counted.

| `p` | `T` | keys `K = p^{T+1}` | max. constrained keys | `IndepT` needs `≤ K/M^T = p` |
|----:|----:|-------------------:|----------------------:|-----------------------------:|
| 3 | 1 | 9 | 3 | 3 |
| 5 | 1 | 25 | 5 | 5 |
| 5 | 2 | 125 | 5 | 5 |
| 7 | 2 | 343 | 7 | 7 |
| 7 | 3 | 2401 | 7 | 7 |

The count is **exactly** `p` in every case — the constrained keys are precisely
the `p` constant polynomials — so `polyHash_indepT` is tight, and the
interpolation lemma `polyEval_injective_of_agree_on_points` is the right reason.

### 2. Why the coding-theoretic route to Conjecture E fails

For a 2-universal family the hash vectors form a code of length `K` over an
alphabet of size `M` with pairwise distance `≥ K(1 − 1/M)`.  Substituting this
into the Plotkin double count gives `N(N−1)·K(1−1/M) ≤ K(1−1/M)·N²`, i.e.
`N(N−1) ≤ N²` — true for every `N`, hence no bound; the Cauchy–Schwarz
second-moment count degenerates in the same way to `n/M ≤ n`.  This is a genuine
*negative* experimental finding: it redirected the proof to the integrality
argument (`K < M ⇒ every collision count is 0 ⇒ every hash is injective`), which
is what `universal2_key_ge_codes` formalizes.

### 3. The tunable Markov trade-off (Conjecture C)

Constants `(c₁, c₂) = (1+η, 1+1/η)` satisfy `1/c₁ + 1/c₂ = 1` exactly, so the
two bad-key sets always leave a key free:

| `η` | silent constant `1+η` | failure constant `1+1/η` | `1/c₁ + 1/c₂` |
|----:|----------------------:|-------------------------:|--------------:|
| 1    | 2.0  | 2.0  | 1 |
| 0.5  | 1.5  | 3.0  | 1 |
| 0.1  | 1.1  | 11.0 | 1 |
| 0.01 | 1.01 | 101.0| 1 |

The silent-error constant tends to the first-moment optimum `1`; whether it is
attained is Conjecture H.
