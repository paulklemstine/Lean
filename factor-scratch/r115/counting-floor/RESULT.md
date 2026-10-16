# Axis D — the counting floor for Semaev-style index calculus on `E(F_p)`

Round 115, subagent axis D. Deliverable directory: `factor-scratch/r115/counting-floor/`.

```
SemaevCountingFloor.lean      the Lean 4 file (Mathlib only, no catalog imports)
verified_table.txt           the captured #eval output of that file (exit status 0)
waiting_time_crosscheck.sage Sage cross-check of the waiting-time form (Parts 1–3)
sage_crosscheck_output.txt   captured output of the Sage script (Parts 1–3 PASS)
RESULT.md                    this file
```

## 1. The claim

Let `G` be a commutative group (additive notation), `S : Finset G` a factor base of
cardinality `B = #S`, and

```
kSums S k = { P₁ + ⋯ + P_k : P_i ∈ S }        (Minkowski power; repetitions allowed)
```

the set of points that a `k`-term decomposition with factor base `S` can express at all.
Then, **unconditionally**, in any commutative group:

> **(C1) Counting floor.** `#(kSums S k) ≤ #S ^ k`.
> **(C2) Fraction of the group.** If `G` is finite of order `N`, then the proportion of
> `k`-decomposable points is at most `B^k / N` (as an exact rational inequality).
> **(C3) Pigeonhole.** If `B^k < N`, some point of `G` is *not* `k`-decomposable.
> **(C4) Strategy independence.** For *any* finite family `Φ` of `k`-tuples of factor-base
> elements, `#((fun f ↦ ∑ i, f i) '' Φ) ≤ B^k` — no solver, however clever, can reach more
> distinct group elements than there are tuples.
> **(C5) Relation-collection cost.** With `M` independent uniform draws from `G`, the
> probability of obtaining at least one `k`-decomposable point is at most `M · B^k / N`; hence
> the expected number of hits per draw is at most `B^k / N`, and the waiting time between
> successive relations is at least `N / B^k` draws.

All of C1–C5 hold for `G = E(F_p)` with `n = 1`, which is exactly the setting in which
Galbraith–Gaudry (§6.2) describe Semaev's small-abscissa factor base.  Nothing about elliptic
curves is used: the floor is a statement about the cardinality of a factor base.

## 2. The exact Lean statements (all machine-checked, no `sorry`/`axiom`/`native_decide`)

```lean
variable {G : Type*} [AddCommGroup G] [DecidableEq G]

def kSums (S : Finset G) : ℕ → Finset G
  | 0 => {0}
  | k + 1 => Finset.image₂ (· + ·) (kSums S k) S

@[simp] theorem kSums_zero (S : Finset G) : kSums S 0 = {0} := rfl
@[simp] theorem kSums_succ (S : Finset G) (k : ℕ) : kSums S (k + 1) = kSums S k + S := rfl
@[simp] theorem kSums_one (S : Finset G) : kSums S 1 = S := ...
theorem mem_kSums_iff (S : Finset G) (k : ℕ) (x : G) :
    x ∈ kSums S k ↔ ∃ f : Fin k → G, (∀ i, f i ∈ S) ∧ ∑ i, f i = x
theorem kSums_mono (S T : Finset G) (h : S ⊆ T) (k : ℕ) : kSums S k ⊆ kSums T k

-- C1
theorem kSums_card_le (S : Finset G) (k : ℕ) : (kSums S k).card ≤ S.card ^ k

-- C4
theorem family_sums_card_le (S : Finset G) (k : ℕ) (Φ : Finset (Fin k → G))
    (hΦ : ∀ f ∈ Φ, ∀ i : Fin k, f i ∈ S) :
    (Φ.image (fun f => ∑ i, f i)).card ≤ S.card ^ k
theorem solver_decomposed_card_le (S : Finset G) (k : ℕ) (Φ : Finset (Fin k → G))
    (hΦ : ∀ f ∈ Φ, ∀ i : Fin k, f i ∈ S) :
    ((Φ.image (fun f => ∑ i, f i)).card : ℝ) ≤ ((S.card ^ k : ℕ) : ℝ)

variable {G : Type*} [AddCommGroup G] [DecidableEq G] [Fintype G]

-- C3
theorem kSums_card_lt (S : Finset G) (k : ℕ) (h : S.card ^ k < Fintype.card G) :
    (kSums S k).card < Fintype.card G
theorem exists_not_mem_kSums (S : Finset G) (k : ℕ) (h : S.card ^ k < Fintype.card G) :
    ∃ x : G, x ∉ kSums S k

-- C2 (rational form is the "proportion" one; the ℕ form is also proved)
theorem kSums_card_div_le (S : Finset G) (k : ℕ) (hN : 0 < Fintype.card G) :
    ((kSums S k).card : ℚ) / Fintype.card G ≤ (S.card ^ k : ℚ) / Fintype.card G
theorem kSums_card_div_le_nat (S : Finset G) (k : ℕ) :
    (kSums S k).card / Fintype.card G ≤ S.card ^ k / Fintype.card G

-- single-draw probability (Mathlib's own uniform distribution)
theorem uniform_hit_prob (A : Finset G) (hG : Nonempty G) :
    (PMF.uniformOfFintype G).toOuterMeasure (A : Set G) = A.card / Fintype.card G

-- sampling statements behind C5
theorem card_full {M : ℕ} : (Finset.univ : Finset (Fin M → G)).card = Fintype.card G ^ M
theorem card_noHitEvent (A : Finset G) (M : ℕ) :
    (noHitEvent A M).card = (Fintype.card G - A.card) ^ M
theorem card_hitEvent (A : Finset G) (M : ℕ) :
    (hitEvent A M).card + (noHitEvent A M).card = Fintype.card G ^ M
theorem no_hit_prob (A : Finset G) (M : ℕ) (hle : A.card ≤ Fintype.card G) :
    tupleProb M (noHitEvent A M) = (((Fintype.card G - A.card : ℚ) / Fintype.card G) ^ M)
theorem hit_prob (A : Finset G) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent A M) = 1 - (((Fintype.card G - A.card : ℚ) / Fintype.card G) ^ M)
theorem bernoulli_sub (q : ℚ) (hq0 : 0 ≤ q) (hq1 : q ≤ 1) (M : ℕ) : 1 - q ^ M ≤ M * (1 - q)
theorem hit_prob_le (A : Finset G) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent A M) ≤ (M * (A.card : ℚ)) / Fintype.card G

-- C5, with the counting floor plugged in
theorem decomposable_hit_prob_le (S : Finset G) (k : ℕ) (M : ℕ) (hN : 0 < Fintype.card G) :
    tupleProb M (hitEvent (kSums S k) M) ≤ (M * ((S.card ^ k : ℕ) : ℚ)) / Fintype.card G
```

**Design choices, and why.**  (i) The proportion is stated over `ℚ`, not `ℕ /`: the
cryptanalytic quantity is a *proportion* (of order `2^-128` at 256 bits), which integer
division floors to `0`.  The `ℕ /` version is proved alongside (`kSums_card_div_le_nat`) for
callers that want it.  (ii) `kSums` is stated for an arbitrary `[AddCommGroup G]`, not for
finite groups, because the floor is genuinely a statement in infinite groups too.  (iii) The
"point at infinity" / zero element: `kSums S 0 = {0}` is the empty sum, and `kSums S 1 = S`.

**What is *not* in Lean.**  The waiting-time half of C5, `E[T] ≥ N / B^k`, is stated as a
docstring comment, not a theorem.  Formalising `E[T] = ∑_m ℙ(T > m)` needs the
measure-theoretic tail-sum identity for a `ℕ`-valued random variable, which is a different
machinery from the counting floor.  Instead the probability statements that the floor rests on
(`no_hit_prob`, `hit_prob`, `hit_prob_le`) are proved, and the geometric expectation is
cross-checked numerically by Sage (Part 2 below) — this was explicitly allowed by the brief.

## 3. The falsifier

Any one of the following refutes this work; all are machine-checkable:

1. **A counterexample to the floor.** A commutative group `G`, a finite `S ⊆ G` and a `k`
   with `#(kSums S k) > #S ^ k`.  (There is none: this is a pigeonhole on the tuples.)
   ```lean
   example (S : Finset (ZMod 7)) (k : ℕ) : (kSums S k).card ≤ S.card ^ k :=
     kSums_card_le S k
   ```
2. **A solver that beats C4.** A family `Φ` of `k`-tuples of elements of `S` whose sums have
   more than `B^k` distinct values.  (Impossible: the sums of tuples from `S` are exactly
   `kSums S k`.)
3. **A wrong probability model.** A finite `A ⊆ G`, an `M ≤ #⟨Fin M → G⟩`-large sample and an
   enumeration contradicting `hit_prob` / `no_hit_prob` / `hit_prob_le`.  Sage Part 1 checks
   this exhaustively for all `(N, a, M)` in `(7,3), (7,1), (11,2), (13,5) × {1,2,3,4}` — 16
   exhaustive cases, all exact.
4. **A sub-rho collection cost in a regime the floor kills.** A `(B, k)` with `B^k ≤ √N` and
   a demonstrated collection cost below `√N`.  Table B shows the floor is `≥ √N = 2^128`
   everywhere in that regime.

## 4. Reproduce

```bash
# the Lean file (Mathlib only; no catalog imports; lake build NOT run)
cd /home/raver1975/lean/Catalog && lake env lean \
  /home/raver1975/lean/factor-scratch/r115/counting-floor/SemaevCountingFloor.lean \
  | tee factor-scratch/r115/counting-floor/verified_table.txt
# exit status 0, no errors, no warnings; full #eval table in verified_table.txt

# the Sage cross-check (exact probabilities + seeded Monte Carlo + 256-bit arithmetic)
cd /home/raver1975/lean/factor-scratch/r115/counting-floor && \
  timeout 900 ~/sage_mamba/envs/sage/bin/sage waiting_time_crosscheck.sage
```

## 5. The verified table (from `#eval`, see `verified_table.txt`)

### Positive controls (they must fire before a null means anything)

```
=== POSITIVE CONTROL 1 (tightness at k=1; the bound is attained) ===
  G = ZMod (2^31-1), B = 4,  S = {0,...,B-1}: #(kSums S 1) = 4,   bound = 4
  G = ZMod (2^31-1), B = 8,  S = {0,...,B-1}: #(kSums S 1) = 8,   bound = 8
  G = ZMod (2^31-1), B = 16, S = {0,...,B-1}: #(kSums S 1) = 16,  bound = 16
=== POSITIVE CONTROL 2 (full coverage in the vacuous regime) ===
  G = ZMod 5, S = {1,-1}:
    k = 1: #(kSums S k) = 2, bound = 2,  #G = 5
    k = 2: #(kSums S k) = 3, bound = 4,  #G = 5
    k = 3: #(kSums S k) = 4, bound = 8,  #G = 5
    k = 4: #(kSums S k) = 5, bound = 16, #G = 5     <-- the 4-fold sums FILL ZMod 5
```

Control 1 confirms `kSums` computes what it should (the bound is attained exactly at `k = 1`).
Control 2 confirms the *opposite*: at `k = 4` with `B = 2` and `#G = 5` the bound `B^k = 16 ≥ 5`
is vacuous, and the truth is nevertheless **full coverage** — so the VACUOUS rows below are not
an artifact of the bound; the machinery can see when `kSums` fills the group.

### Table A — exact `#(kSums S k)` in `G = ZMod (2^31-1)`, `S = {0,…,B-1}`

`interval` is the closed form `min(N, k(B-1)+1)` for this `S`, independently recomputed and
compared; every row agrees.

```
B    k   B^k          #kSums  interval     B^k/N              draws>=      status
4    2   16           7       7  OK        16/2147483647      134217728    INFORMATIVE
4    3   64           10      10 OK        64/2147483647      33554432     INFORMATIVE
4    4   256          13      13 OK        256/2147483647     8388608      INFORMATIVE
4    5   1024         16      16 OK        1024/2147483647    2097152      INFORMATIVE
4    6   4096         19      19 OK        4096/2147483647    524288       INFORMATIVE
4    8   65536        25      25 OK        65536/2147483647   32768        INFORMATIVE
8    2   64           15      15 OK        64/2147483647      33554432     INFORMATIVE
8    3   512          22      22 OK        512/2147483647     4194304      INFORMATIVE
8    4   4096         29      29 OK        4096/2147483647    524288       INFORMATIVE
8    5   32768        36      36 OK        32768/2147483647   65536        INFORMATIVE
8    6   262144       43      43 OK        262144/2147483647  8192         INFORMATIVE
8    8   16777216     57      57 OK        16777216/2147483647 128         INFORMATIVE
16   2   256          31      31 OK        256/2147483647     8388608      INFORMATIVE
16   3   4096         46      46 OK        4096/2147483647    524288       INFORMATIVE
16   4   65536        61      61 OK        65536/2147483647   32768        INFORMATIVE
16   5   1048576      76      76 OK        1048576/2147483647  2048        INFORMATIVE
16   6   16777216     91      91 OK        16777216/2147483647 128         INFORMATIVE
16   8   4294967296   121     121 OK       4294967296/2147483647 1        VACUOUS
32   2   1024         63      63 OK        1024/2147483647    2097152      INFORMATIVE
32   3   32768        94      94 OK        32768/2147483647   65536        INFORMATIVE
32   4   1048576      125     125 OK       1048576/2147483647  2048        INFORMATIVE
32   5   33554432     156     156 OK       33554432/2147483647 64          INFORMATIVE
32   6   1073741824   187     187 OK       1073741824/2147483647 2         INFORMATIVE
32   8   1099511627776 249    249 OK       1099511627776/2147483647 1      VACUOUS
64   2   4096         127     127 OK       4096/2147483647    524288       INFORMATIVE
64   3   262144       190     190 OK       262144/2147483647  8192         INFORMATIVE
64   4   16777216     253     253 OK       16777216/2147483647 128         INFORMATIVE
64   5   1073741824   316     316 OK       1073741824/2147483647 2         INFORMATIVE
64   6   68719476736  379     379 OK       68719476736/2147483647 1        VACUOUS
64   8   281474976710656 505   505 OK      281474976710656/2147483647 1   VACUOUS
```

Both regimes are present and the boundary is where theory says it must be: `B^k < N`
(`INFORMATIVE`) in 26 rows, `B^k ≥ N` (`VACUOUS`) in 4 rows, with the last informative row
`B = 32, k = 6` sitting at `B^k/N = 1/2`.

**Looseness (honest).**  In a commutative group the bound `B^k` is *systematically* loose for
`k ≥ 2`: `a + b = b + a`, so at most `C(B + k - 1, k) ≤ B^k / k!` distinct sums are possible,
and for the interval `S` of Table A the exact count is `min(N, k(B-1) + 1)`, e.g. `505` for
`B = 64, k = 8` against the bound `2^48`.  This does not weaken C5 — it makes the floor
*conservative*: the true cost is at least `N / B^k`, not equal to it.  It does mean that a
`B^k` which happens to exceed `N` is *not* evidence that the group is covered (Table A's
`B = 64, k = 6` row: bound `2^36`, actual `379`).

### Table B — the 256-bit deployment (`N = secp256k1` order, `√N = 2^128`)

`draws` is `⌈N / B^k⌉`, the counting floor on the number of random draws per relation; the
row is "killed" when that floor is at least the generic Pollard-rho cost `√N`.

```
B        k   log2(B^k)  log2 ceil(N/B^k)  verdict
2^8      2      16        239             FLOOR >= RHO (killed)
2^8      3      24        231             FLOOR >= RHO (killed)
2^8      4      32        223             FLOOR >= RHO (killed)
2^8      5      40        215             FLOOR >= RHO (killed)
2^8      6      48        207             FLOOR >= RHO (killed)
2^8      8      64        191             FLOOR >= RHO (killed)
2^8      10     80        175             FLOOR >= RHO (killed)
2^16     2      32        223             FLOOR >= RHO (killed)
2^16     3      48        207             FLOOR >= RHO (killed)
2^16     4      64        191             FLOOR >= RHO (killed)
2^16     5      80        175             FLOOR >= RHO (killed)
2^16     6      96        159             FLOOR >= RHO (killed)
2^16     8     128        127             FLOOR >= RHO (killed)
2^16     10    160         96             floor < rho
2^20     2      40        215             FLOOR >= RHO (killed)
2^20     3      60        195             FLOOR >= RHO (killed)
2^20     4      80        175             FLOOR >= RHO (killed)
2^20     5     100        155             FLOOR >= RHO (killed)
2^20     6     120        135             FLOOR >= RHO (killed)
2^20     8     160         96             floor < rho
2^20     10    200         56             floor < rho
2^24     2      48        207             FLOOR >= RHO (killed)
2^24     3      72        183             FLOOR >= RHO (killed)
2^24     4      96        159             FLOOR >= RHO (killed)
2^24     5     120        135             FLOOR >= RHO (killed)
2^24     6     144        112             floor < rho
2^24     8     192         64             floor < rho
2^24     10    240         16             floor < rho
2^32     2      64        191             FLOOR >= RHO (killed)
2^32     3      96        159             FLOOR >= RHO (killed)
2^32     4     128        127             FLOOR >= RHO (killed)
2^32     5     160         96             floor < rho
2^32     6     192         64             floor < rho
2^32     8     256          0             floor < rho
2^32     10    320          0             floor < rho
2^40     2      80        175             FLOOR >= RHO (killed)
2^40     3     120        135             FLOOR >= RHO (killed)
2^40     4     160         96             floor < rho
2^40     5     200         56             floor < rho
2^40     6     240         16             floor < rho
2^40     8     320          0             floor < rho
2^40     10    400          0             floor < rho
2^64     2     128        127             FLOOR >= RHO (killed)
2^64     3     192         64             floor < rho
2^64     4     256          0             floor < rho
2^64     5     320          0             floor < rho
2^64     6     384          0             floor < rho
2^64     8     512          0             floor < rho
2^64     10    640          0             floor < rho
```

(`log2 = 0` means `⌈N/B^k⌉ = 1`: the bound `B^k` is so large that the floor is vacuous in
that row — the *collection* cost is then trivially 1 draw, which is exactly why those rows
carry no information.)

### Sage cross-check output (Parts 1–2)

```
PART 1: exact enumeration vs closed form   (Lean `hit_prob`, `no_hit_prob`)
     N    a    M          exact    closed form    match
     7    3    1              3/7            3/7      YES
     7    3    2             33/49          33/49      YES
     7    3    3           279/343         279/343     YES
     7    3    4          2145/2401       2145/2401    YES
     7    1    1              1/7            1/7      YES
     7    1    2             13/49          13/49      YES
     7    1    3           127/343         127/343     YES
     7    1    4          1105/2401       1105/2401    YES
    11    2    1             2/11           2/11      YES
    11    2    2            40/121         40/121     YES
    11    2    3           602/1331        602/1331    YES
    11    2    4          8080/14641      8080/14641    YES
    13    5    1             5/13           5/13      YES
    13    5    2           105/169         105/169     YES
    13    5    3          1685/2197       1685/2197    YES
    13    5    4         24465/28561     24465/28561    YES
PART 1 verdict: closed form matches exact enumeration everywhere: True

PART 2: Monte-Carlo first-hit waiting time E[T] vs the floor N/a
         N      a       N/a      mean(T)    geometric    match
       101      5     20.20        20.45        20.20      YES
       503      7     71.86        72.88        71.86      YES
     10007    100    100.07       102.80       100.07      YES
PART 2 verdict: empirical mean waiting time tracks N/a within 5%: True
```

## 6. Deduplication — what was already in the catalog

Searched with `grep -rn … --include=*.lean Catalog/` (the `.lake/packages/mathlib` build and
olean directories were excluded; hits there are Mathlib's own, not the campaign's):

| search | found in the catalog? |
|---|---|
| `kSums` | **no** (only Mathlib's `rankSums` inside `Tactic/MoveAdd`) |
| `image₂` / `image2` | **no** catalog source uses it |
| `Semaev` | **no** |
| `index calc` / `indexcalc` | **no** |
| `factor base` | `Bridges/QSFactorBaseDimension.lean`, `Bridges/QRLotto*.lean` — these are *quadratic-sieve* results (support of a relation over admissible primes, `𝔽₂` dimension ⇒ congruence of squares); no elliptic-curve sumset bound, no `kSums` |
| `card_image_le` | used in `Bridges/DenseSumsetFree/{Extraction,General,Counting,Triple}.lean`, `Bridges/{UltrametricProofObserverRateDistortion,TropicalCryptoMLBridge,IdempotentThermodynamicRealization,OperadicTropicalization}`, `Bridges/NeuralCoding/*` — all for *other* results. The closest relative, `Bridges/DenseSumsetFree/`, proves existence of dense subsets of `ℤ/n` containing no sumset of a pair of `l`-element lists (`sumsetNat` is a `List`-folded sumset, not the Minkowski power of a factor base in a group); it contains no floor of the form `#(kSums) ≤ B^k`, no proportion/waiting-time statement, and no strategy-independence bound. |
| `Finset.image₂_le` / `card_le_of_surjOn` | no catalog source uses `card_le_of_surjOn` at all |
| `uniformOfFintype` | `Cryptography/ZeroKnowledgeTheoremProving.lean` (ZK hiding), unrelated |
| `piFinset` | `Bridges/ChartWeightedCertificates.lean`, `Bridges/ChartSimplexUnisolvence.lean` (Schubert charts), unrelated |
| `Minkowski` | `Bridges/TropicalGeometricLanglandsMV.lean`, `Bridges/algebra_physics_bridge_theorem.lean`, `Bridges/BerggrenLatticeReduction.lean` — all other meanings (pointwise set addition, null cones, lattice bounds); none is the group-law Minkowski power of a factor base |

**Conclusion: the counting floor for Semaev-style index calculus is not in the catalog.** The
result is new to this repository.  (It is of course not new to mathematics — it is a pigeonhole
argument; what is new is that it is now machine-checked, stated in the form that bounds every
heuristic claim in the family, and measured at 256-bit parameters.)

## 7. Honest verdict

**Status: the floor is SUPPORTED (machine-checked), and it kills a well-defined family of
claims. It does not kill index calculus on prime-field elliptic curves.**

What the floor **does** rule out:

* Any claimed decomposition/relation-collection scheme with a factor base `S` and a fixed
  number of terms `k` such that `B^k ≤ √N` cannot collect relations below the generic
  Pollard-rho cost `c·√N` — counting alone forces `⌈N/B^k⌉ ≥ √N` draws (Table B, the
  "FLOOR >= RHO" rows).  This is unconditional: `family_sums_card_le` makes it independent of
  the solver's cleverness, and `exists_not_mem_kSums` shows that in this regime some points
  are *never* decomposable.
* Any claim that a *specific* small `(B, k)` covers the group: if `B^k < N`, at least one
  point is out of reach, no matter what the decomposition algorithm is.

What the floor **does NOT** rule out:

* Schemes with a large factor base and many terms.  Table B is explicit: with `B = 2^40`
  (≈10¹² factor-base points) and `k = 4`, the floor is `⌈N/B^k⌉ = 2^96`, i.e. **below** rho by
  a factor `2^32`.  Counting alone leaves that regime open; what rules it out is
  (a) the *decomposition problem* — Galbraith–Gaudry: *"the elliptic group law is deeply
  incompatible with the multiplication of the integers representing the abscissae of the
  points"* and *"right now, there is no known efficient decomposition algorithm for that
  choice of F"* — and (b) engineering costs (storing and enumerating `2^40` curve points)
  which are not theorems.  This file does not touch either.
* Any statement about the *difficulty of computing* a decomposition of a decomposable point.
  C1–C5 are upper bounds on the **supply** of decompositions, hence lower bounds on the
  **collection cost**.  They say nothing about the complexity of the summation-polynomial
  system for a point that is (rarely) decomposable.
* Nothing here is a claim about `E(F_{p^n})` with `n ≥ 2`, where Weil descent and Diem's
  rigorous `L[2/3]` result live (different machinery entirely; see `ECDSA_BRIEF.md` §1).

**The floor's role in the campaign.**  It is a **hard floor under every heuristic claim in the
Semaev family**: any proposal must first pay `N / B^k`, whatever the solver.  It converts a
vague "we believe there is no fast decomposition" into a quantified debt.  The decomposition
problem itself — the actual blocker, per the fetched Galbraith–Gaudry text — remains open, and
this file does not claim otherwise.
