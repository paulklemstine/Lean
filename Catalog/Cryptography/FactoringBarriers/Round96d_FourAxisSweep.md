# Round 96d — a four-axis sweep: quantum, special-form, theory, and design alignment

**2026-10-04. Still NO new factoring algorithm and NO exponent improvement.** This
round fanned four parallel subagents across distinct axes of the factoring
landscape, then machine-tested the one axis the catalog suggested might evade
the round-96b birthday obstruction. Every axis returns a **negative or
already-closed** result, and this note records them together with the *reason*
each is closed. The design-alignment axis is a new, quantified negative.

Empirical companion: `Experiments/UMWWindow/design_alignment.py` (deterministic;
`out_design.txt` committed). No new Lean.

---

## 1. Axis A — Quantum factoring: closed, and not by much

* **No asymptotic opening exists.** Nothing beats Shor's `poly(log N)`. The 2024–2026
  record is all *depth* and *space*: Regev's high-dimensional family goes from
  `Õ(n^{3/2})` gates × `√n` runs to `O(n log n)` space (arXiv:2511.18198,
  SORA; Luo–Li–Le Gall arXiv:2609.36480 reduce gate count `Õ(n²)→Õ(n^{3/2})`
  for Abelian decomposition), and Vandaele (arXiv:2603.12917) cuts Shor's
  **depth** `O(n³)→O(n²log²n)`. **Total time / gate count: no improvement.**
* Ekerå–Gärtner (arXiv:2405.14381) is the honest verdict: Regev's space
  savings "do not achieve an advantage … more computational memory … more
  work, per run and overall."
* Practical floor: Gidney 2025 (arXiv:2505.15917) — RSA-2048 in **< 10⁶ noisy
  qubits, < 1 week** — an *analytical* estimate, and he himself bounds the
  headroom ("no way to reduce by another order of magnitude"). Hardware
  factoring has never exceeded `N≈21` (Shor) / `35` (Regev).
* 2026 lower bounds (Cai–Young arXiv:2609.24316; Dong–Lombardi arXiv:2610.02101)
  argue from the *cryptanalytic* side that polynomial-time + good space is
  essentially optimal. **Axis closed.**

## 2. Axis B — Special-form / partial-information factoring: real sub-`L[1/3]`, but all need a promise

These are genuine improvements *for promised `N`* — the strongest classical
results below `L[1/3]`, none of which touch the general case:

| promise | bound | status |
|---|---|---|
| `N` with small-algebraic form | `L[1/3,(32/9)^{1/3}]` vs GNFS `L[1/3,(64/9)^{1/3}]` | heuristic, constant `2^{1/3}≈1.26` only |
| `p,q` close, `\|p−q\|=O(N^{1/4})` | polynomial (Fermat) | **proved** |
| top `n/4` bits of `p` known | polynomial (Coppersmith '96, Rivest–Shamir `1/3`) | **proved** |
| `ln2≈70%` bits of `p`, arbitrary positions | poly for `O(log log N)` blocks | heuristic (Herrmann–May) |
| `0.27` fraction of RSA key bits | poly (Heninger–Shacham) | **proved** |
| `ℓ=2` public-exponent pairs | `N^{(9ℓ−4)/(36ℓ)}=N^{0.194}` (Aono, Minkowski-sum) | heuristic |

* There is **no classical sub-`L[1/3]` special form**; SNFS's only asymptotic
  content is the `1.26×` constant. Hidden SNFS (Fried et al. arXiv:1610.02874)
  is a trapdoor, not a general method.
* The Coppersmith `n/4`-bits-of-`p` law is the sharpest proved sub-`L[1/3]`
  promise result and is **exactly the "which factor / hint" family the record
  already mined.** **Axis yields promises, not an algorithm.**

## 3. Axis C — The theory frontier: `1/5` confirmed, UMW's clean variant refuted

This is the axis that matters for the record, and it independently reproduces
what the repo already knew (`RESEARCH.md` item 1):

* **Deterministic `1/5` stands.** Harvey–Hittmeir, arXiv:2105.11105 / *Math.
  Comp.* **91** (2022): `O(N^{1/5} log^{16/5}N / (log log N)^{3/5})` — the
  exact record. Oznovich–Volk (arXiv:2506.07668) lowers a *component*
  threshold (`D≥N^{1/6}`) but **does not move the exponent** (the repo verified
  this in Round 49 §1a).
* **He–Sahai (arXiv:2608.06681) refute the arithmetic-progression version** of
  the UMW conjecture at `(1/3,1/3)`: an `n`-divisor AP of height `exp(o(√n))`
  needs length `≥ (√(8/27)−o(1))·n^{3/4}/√(log n)`. This **kills the cleanest
  UMW instantiation** but explicitly leaves the higher-rank Strong Conjecture
  open. (Reportedly AI-generated and unreviewed — treat as *claimed*.)
* **GNFS `L[1/3]` unchanged**; class-group / lattice / algebraic-geometry all
  worse in the L-sense for balanced `N`. UMW's `1/6` is a *deterministic* bound
  and does not compete with GNFS in the heuristic `L`-sense.

**So the program's standing target — beat `1/5` via a rank-2 GAP divisor cover
in the window `[1/3,2/5)` — remains the only live door, and He–Sahai has made
it harder, not easier.**

## 4. Axis D — Design-theoretic alignment: a new quantified negative

The catalog contains formalized **perfect difference sets** (flat difference
profile, `DifferenceSetFlatProfile.lean`) and **Sidon sets in cyclic groups**
(`SidonSetsCyclic.lean`) — sets whose pairwise differences are provably
*maximally spread*. Spread differences are exactly what the round-96b birthday
obstruction rewards, so a difference set is the natural candidate to **evade**
the obstruction.

**Test** (`design_alignment.py`): take `S` = a Singer `(v,k,1)` perfect
difference set and `T` = a disjoint copy (so no difference is `0` — the
vacuity Round 49 flagged), and compare the coverage of `[n]` against a random
`S` of the *same size*, as `n` grows far past `v`.

| `v`,`k` | ratio design/random at `n = v, 2v, 4v, 8v, 16v` |
|---|---|
| (7,3) | 1.00, 0.99, 0.96, 0.97, 1.02 |
| (13,4) | 1.00, 1.02, 1.03, 1.05, 1.04 |
| (21,5) | 1.00, 1.05, 1.04, 1.06, 1.03 |
| (31,6) | 1.00, 1.04, 1.04, 1.03, 1.03 |

> **The design/random ratio stays ~1.0–1.06 at every scale.** Perfect
> difference sets buy a **constant factor, not an exponent** — the same
> birthday decay. Flatness of differences mod `v` says nothing about their
> distribution mod each `i ≤ n`, so the design does **not** evade the
> obstruction. **Negative result.**

*(An earlier draft of this test reported a dramatic "100% vs 50%" gain; that
was a **vacuity bug** — `0 ∈ S` makes every `i | 0`, exactly the defect Round
49 §4d flagged in UMW's own Definition 3.1. The disjoint-set version above is
the honest one.)*

---

## 5. Honest scope

* **No new factoring algorithm. No complexity beaten. No axis opened.**
* What this round adds: an independent confirmation of the whole frontier
  (`1/5` deterministic, `L[1/3]` heuristic, Shor unbeatable, UMW's AP variant
  refuted), a tabulation of the genuine sub-`L[1/3]` **promise-class** results
  (Coppersmith/SNFS/Heninger–Shacham/Aono) so they are not re-hunted, and one
  new **measured negative** (design alignment does not evade the birthday
  obstruction).
* **Not claimed:** that no aligned cover exists. Only that random, hill-climbed,
  and design-theoretic covers all fail to beat exponent `1/4`, and that the
  remaining door (a *deliberately* aligned GAP cover, `γ<0.4`) is un-built.

**Next attack (unchanged priority from 96b/96c, now sharper).** The birthday
obstruction predicts that *any* cover of size `n^γ`, `γ<1/2`, leaves gaps. The
single highest-value move remains to **prove that for GAP covers** — which
would close the whole window rigorously. A counterexample search at moderate `n`
with rank-3/4 GAPs is the natural falsification test.