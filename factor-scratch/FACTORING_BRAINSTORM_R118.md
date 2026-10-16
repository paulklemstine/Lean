# Brainstorm: novel *factoring* algorithms inspired by the Catalog's Lean work

Round 118, `factor-scratch/FACTORING_BRAINSTORM_R118.md`.
**Ground rule taken from the catalog itself:** `Catalog/Cryptography/FactoringBarriers/`
is a **27-entry kill record** with five machine-checked barrier theorems, so a brainstorm
that ignores it re-proposes dead directions. This file therefore (1) states what the
catalog actually establishes, (2) derives what the barriers *leave* open, and (3) proposes
only directions that live in that residue, each with a falsifiable experiment.

## 1. What the catalog establishes (verified by reading the files)

| asset | location | content |
|---|---|---|
| **range/injectivity barrier** | `FactoringBarriers/FactorEncodingAudit.lean`, `fixed_range_cannot_be_injective` | a handle recovering `p` must be **injective across the `n`-bit semiprimes** `S_n`, hence need `log₂|S_n| = n − Θ(log n)` bits of range; a fixed structure has `O(1)`. Pure pigeonhole — no `P≠NP`, no GRH |
| **`n/4` partial-key wall** | `FactorEncodingAudit.lean`, `known_leak_maximized_at_balanced` | the known-bits budget `(β−β²)n` is **maximised at `β = 1/2`**, where it is `n/4`; balance is what makes the barrier worst. Also `fourdii_printed_step_false` etc., correcting a published derivation |
| **mod-4 non-injectivity** | `NegativeResults.lean`, `mod4_not_injective` | three semiprimes all `≡ 3 mod 4` are not separated by the residue class |
| **cold-boot noise** | `NegativeResults.lean`, `coldboot_noise_below_capacity` | real remanence decay is *cleaner* than the whole-key methods can use |
| **Berggren tree facts** | `Cryptography/BerggrenModular/`, `berggren_hyp_prime_divisors_one_mod_four` | **every prime divisor of a Pythagorean hypotenuse is `≡ 1 mod 4`** — a machine-checked factorisation-structure theorem |
| **Fermat-node sufficient statistic** | `FactorEncodingAudit.lean` | for the node `(m,n)` of `N`, `p² = N(r−1)/(r+1)`, so the ratio `r = m/n` **is** a sufficient statistic for `p` |
| **Pillai/gcd-gap machinery** | `NumberTheory/PillaiEquations.lean` | gcd-gap equations, Catalan-type classifications |
| **source-coding apparatus** | `Cryptography/UniversalRedundancy*.lean` (6 files) | Shtarkov sums, `libraryClass`, `maxLik`, greedy feature selection, submodularity |
| **Newton–tropical bridge** | `Cryptography/Newtontropicalbridge/`, `TropicalAlgebra/` | tropical algebra + Newton polygons, formalized |
| **isogeny/volcano machinery** | `Cryptography/IsogenySIDH/` (14 files) | Kani's lemma, Vélu-style radical maps, 2- and 3-isogeny neighbours, backtracking structure |

## 2. What the barriers *leave* open (the residue)

The kill record closes: fixed structures (range), Tower NFS and amortisation (exponent),
CF-period parity and SQUFOF (Lagrange + `N^{1/4}`), genus characters, the "AGM" phantom,
`1/3`-of-the-`p`-bits claims, memcomputing, resonance encoding, noisy Coppersmith,
cold-boot framing, the Berggren tree as a device (circularity *and* Farey-limited cost),
Berggren spectral resonance (= **Pollard `p−1`**), the Gu–Martin modular-curve counts,
ℓ-adic skeletons (functions of `N mod ℓᵏ`), adaptive smoothness, Reed–Solomon key models,
Pell/Størmer, moment quotients, diagonalisation, and tree-order search.

So an admissible new algorithm must be an **`N`-dependent handle with `n − Θ(log n)` bits of
range that is cheaper than `L[1/3]` to obtain**. The only known cheap source of such range
is relation collection (the sieve paradigm). **Everything below is inside that residue, and
each item says which of "new algorithm / new theorem / sieve-in-disguise" it is.**

## 3. Proposed directions

### F1 — tropical parameterisation of the NFS polynomial-selection geometry *(new engineering, maybe new math)*
**Asset:** `Newtontropicalbridge/`, `TropicalAlgebra/`, `TropicalspectralgraphTheorems/`.
**Idea.** The NFS's soft spot is polynomial selection: choose `φ(x) ∈ ℤ[x]` with small
coefficients, prescribed Newton polygon, and good root properties. Kleinjung's approach
lattices the coefficient space; **tropical geometry is the valuation shadow of exactly this
problem**, and the catalog has it formalized. A tropical parameterisation of the "size
function" (`ℓ∞`, `ℓ₂`, skewness) over the Newton-polygon polytope gives a different
candidate family than the lattice-reduction one.
**Falsifier:** implement the tropical selection, run it against Kleinjung's
`polyselect`-style selection on the same moduli; if the resulting `α` (root quality) and
relation yield do not improve by a measurable factor, it is dead. **Honest status: this is
optimisation inside `L[1/3]`; the kill record's entry 2 (Tower NFS) already fixes the
exponent, so the ceiling is a constant-factor gain.** Include for the experiment, not for
the exponent.

### F2 — the range barrier as a *channel-capacity* statement *(new theorem, catalog-native)*
**Asset:** `UniversalRedundancy*.lean` (Shtarkov sums, `maxLik`, greedy, submodularity).
**Idea.** The barriers prove the handle must carry `n − Θ(log n)` bits across `S_n` by raw
pigeonhole. The catalog's formalized source-coding apparatus lets you say the same thing as
a **capacity statement**: the semiprime source (uniform on `S_n`) has
`Shtarkov(P, S_n) ≥ log₂|S_n|`, and any "code" for `p` is a library `A` with
`maxLik` recovery; `shtarkov_submodular` + `greedy_one_sub_inv_exp_le` then force the
library size. This **closes the whole "compress/redundancy-reduce the key" family with the
catalog's own machinery**, and it is stronger than pigeonhole in that it also bounds any
*approximate* or list-decoding handle (the story the kill record had to argue for in
prose, entries 19–20).
**Falsifier:** if the Shtarkov formulation does *not* imply the range bound, the transfer
is wrong. **Status: a Lean deliverable, not an algorithm — and it converts two prose
kill-record entries into machine-checked ones.**

### F3 — isogeny-volcano class-group computation as a factoring subroutine *(dominated, but measurable)*
**Asset:** `IsogenySIDH/` (Kani's lemma, `TwoIsogenyNeighbours`, `RadicalWalkStructure`,
`ThreeIsogenyNonBacktracking`), plus `Berggren3Adic/`.
**Idea.** Class-group computation enters factoring through the real-quadratic
infrastructure (kill-record entry 21: `L[1/2,√2]`, dominated). The catalog's verified
isogeny-volcano machinery is the modern tool for that class-group step (Deuring
correspondence). **The falsifiable experiment:** implement the volcano walk in Sage and
compare its `Cl(D)` performance against GNFS-independent sub-exponential baselines
(Hafner–McCurley) at `D` up to `10^30`, measuring the actual distance-from-start and
backtracking rates that the formalized `RadicalNonBacktracking` results bound.
**Status: expected NEGATIVE and dominated by NFS — worth doing *because* the catalog proves
the volcano structure and nobody has measured whether it beats the 1989 algorithm.**

### F4 — the multivariate small-root budget: is there a "balance is worst" barrier? *(open theory, Lean target)*
**Asset:** `FactorEncodingAudit.lean`'s corrected `β − β²` derivation.
**Idea.** The `n/4` wall is sharp for **univariate** small roots. For **multivariate**
Coppersmith (Jochemsz–May "roots with known margins"), the enabling condition is a min over
the margins, and there is no analog of "maximised at `β = 1/2`". The open question: does
the multivariate budget have a *shape* that makes balanced (or some particular) inputs
worst? Answering it decides whether partial-key attacks on multivariate constructions
(e.g. `p ≈ N^β, q ≈ N^{1−β}` with hints on both) are bounded the same way.
**Falsifier:** find a multivariate instance whose known-bit budget is *below* the univariate
wall (i.e. beat `β − β²` with the same leakage). **Status: genuinely open, theorem-shaped,
and formalizable with the catalog's lattice machinery.**

### F5 — the "`p+q` residue" route *(screened closed: the sieve in disguise, but the argument is new)*
**Idea.** `M₁(N) = Σ gcd(x,N) = 4N − 2(p+q) + 1` (the catalog's r26 work, now a Lean
theorem), and `σ(N) = (1+p)(1+q)`: either gives `p+q`, i.e. the factorization. So: can
`(p+q) mod m` be computed in `poly(log N)` for some fixed `m ≥ 2`? CRT over the `~n/2`
small primes would then be polynomial-time factoring.
**Why it closes:** the Fermat node is `m = (p+q)/2, n = (q−p)/2`, so `(p+q) mod m ≡ 2√(N + n²) mod m`; obtaining it means knowing `n mod m`, and each residue divides the
Fermat search by `m` and no more. Summing over the moduli gives `√N/∏m` — which is exactly
relation collection. **Each residue is a relation, not a shortcut.** The catalog's
`mod4_not_injective`/ℓ-adic-unsealedness results are the `k=1` instances of this.
**Status: screened closed by reduction to the sieve; recorded so it is not re-proposed.**

## 4. Recommended order

1. **F2** (Lean, catalog-native, converts prose barriers into machine-checked ones).
2. **F4** (open theory; the answer bounds a whole family of partial-key attacks).
3. **F1** (one afternoon of Sage against a known baseline; expect a constant factor only).
4. **F3** (a real measurement against a 1989 baseline; expect negative).
5. **F5** — do not run; the argument above closes it.

**Framing, stated plainly:** nothing here threatens RSA/ECDLP-scale factoring. The catalog
has already machine-checked why the cheap routes die; what remains is either a constant
inside `L[1/3]`, a theorem about the walls themselves, or the relation-collection paradigm
with a better selection geometry. This file is a record of that residue.


---

# OUTCOME of F1 (applied) — the naive tropical criterion is refuted

`r118/tropical-select/RESULT.md`. Ran it, on ground-truthed instances (`N = p·q`, factors
known, base-`m` polynomials with `φ(m) = N`, 52 candidates, 120 measured smoothness trials
each, fixed seed):

- the **pooled** tropical score `Σ v_p(c_i)` has the largest correlation with the true
  payoff (`r = +0.51`) yet **minimising it selects the worst polynomial in the family**
  (smoothness rate `0.0000`), because the correlation has the wrong sign — the signature of
  a spurious correlation;
- the conditioning control kills it: within degree, the tropical correlation collapses
  from `+0.51` to `−0.06 … +0.43` **and flips sign across degrees**, while the classical
  base-size `|m|` stays at `r ≈ −0.81` pooled (`−0.52 … −0.88` per degree);
- so the pooled tropical signal was the *degree* in disguise (more coefficients ⇒ higher
  valuation sum, and higher `d` ⇒ better payoff), not smoothness.

**Conclusion for F1 as posed: dead.** The p-adic valuations of base-`m` digits are close to
uninformative about the value size `a + bθ`; the classical affine criterion is the one that
works, and it is confirmed under control. What survives, and is recorded as the real next
step, is the *Newton-polygon* formulation — comparing candidate monomial **supports**
rather than coefficient-size statistics — which is what the catalog's
`Newtontropicalbridge` is actually about and which has not been tested.
