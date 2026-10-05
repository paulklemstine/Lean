# r114 — QUANTUM RESOURCE SYNTHESIS: is the yoked-code / rho-parallelisation gap real?

**VERDICT: the gap is NOT real as stated. REFUTED, on four independent grounds.**
The synthesis is not merely a repackaging — it is *negative*: the fusion is
self-defeating. One genuinely new fact emerged (Pinnacle's memory is 11.9x
denser than the yoked cold store), and it kills the idea rather than supporting it.

Ledger status: the campaign memory already recorded a refutation of this fusion
as "a category error", citing a file `r45/axis7/yoked_parallel.md` (592 lines).
**That file does not exist** — not on disk, and a full scan of all 8,862 commits
found it was never committed. The claim was plausible but the evidence was not
recoverable. This round re-derives it from primary sources.

---

## 0. Verification status of the three sources (all fetched, none from memory)

| # | Claim | Status | Evidence |
|---|---|---|---|
| 1 | Gidney 2025 = arXiv:2505.15917 | **VERIFIED** | abs page title: "How to factor 2048 bit RSA integers with less than a million noisy qubits", Craig Gidney, submitted 21 May 2025, **v1 only** (no v2 exists) |
| 2 | "61% cold storage" | **VERIFIED — 61.30%** | Gidney PDF p18, arithmetic reproduced exactly (below) |
| 3 | "Yoked code, 430 phys/logical" | **VERIFIED** | Gidney p18: "yoking with a 2D parity check code reaches a logical error rate of 10−15 when using 430 physical qubits per logical qubit" |
| 4 | Yoked code paper identity | **VERIFIED + UPGRADED** | Not merely a preprint: **"Yoked surface codes", Gidney, Newman, Brooks, Jones, Nature Communications 16, 4498 (14 May 2025), DOI 10.1038/s41467-025-59714-1** (Crossref, author list matches Gidney's own ref [Gid+25] exactly) |
| 5 | Pinnacle = arXiv:2602.11457 | **VERIFIED** | "The Pinnacle Architecture: Reducing the cost of breaking RSA-2048 to 100 000 physical qubits using quantum LDPC codes", Webster, Berent, Chandra, Hockings, Baspin, Thomsen, Smith, Cohen (Riverlane), 12 Feb 2026, rev 5 May 2026 |
| 6 | "Pinnacle needs a read-only input register" | **VERIFIED** | Pinnacle Sec. V.B.3, quoted below |
| 7 | "No paper joins them" | **REFUTED** | Pinnacle's Ref. [8] **is** Gidney arXiv:2505.15917. The parallelisation is built *directly on top of* the paper containing the 61% cold store. They are already joined. |

**Point 7 alone dissolves the premise.** The recorded gap was "no paper connects
the yoked-code result to the parallelisation result". But the parallelisation
paper's own reference [8] is the yoked-code paper's own user. The gap was an
artefact of reading three abstracts, not three papers.

---

## 1. GROUND-TRUTH CONTROLS (the brief's #1 rule)

**This axis is a resource-estimation axis, so the analogue of "vacuous evidence"
is comparing against a trivial baseline. Two controls were run before any claim.**

**Control A — does my model reproduce a known published number?**
```
model: m*q_cold + 131*q_std + compute = 1280*430 + 131*1352 + 170352 = 897,864
Gidney p18 states, verbatim: "The total number of physical qubits is 897864."
MATCH = True
```
The model fires on a known case. It is measuring something.

**Control B — extraction sanity, so that a zero is not a lost glyph.**
```
grep -c 'yoke'     gidney.txt -> 10     (so extraction works)
grep -c 'read'     gidney.txt ->  3
grep -c 'commut'   gidney.txt ->  0     <- genuine zero
grep -c 'parallel' gidney.txt ->  2     (both are a CLEVE-WATROUS REFERENCE, not the algorithm)
```
`commut` = 0 and `parallel` = 0-as-algorithm are **real absences**, not extraction
failures. This confirms the one surviving residual question from the ledger.

---

## 2. The 61% figure — verified, with an internal inconsistency in the paper

Gidney p18, **verbatim**:
> "The m = 1280 input logical qubits are in cold storage, and so cover 1280 · 430 = 550400 physical qubits. The remaining 3f + 2ℓ + len m = 131 logical qubits are in hot storage, and so cover 131 · 1352 = 177112 physical qubits. Finally, the compute region will use a 7x18 region of hot patches (170352 physical qubits)."

> "The total number of physical qubits is 897864."

```
cold fraction = 550400 / 897864 = 61.30%          <- the recorded "61.3%" is CORRECT
```

**But the paper's own hot-register arithmetic is wrong.** Its Table 5 n=2048 row
gives f=33, ℓ=21, m=1280, so len(m)=4 and:
```
3f + 2l + len(m) = 3(33) + 2(21) + 4 = 99 + 42 + 4 = 145      <- paper says 131
```
The paper states 131. Correct is **145**, off by 14 (consistent with the ledger's
note that a digit was dropped from the `l` term). Consequences:
```
as printed:            131*1352 = 177,112 ; total 897,864 ; cold = 61.30%
corrected:             145*1352 = 196,040 ; total 916,792 ; cold = 60.04%
```
So **61.30% is right as printed and 60.04% is right as computed.** The error
understates Gidney's own hot storage, i.e. it flatters the cold fraction. The
headline "61% cold" is not an artefact — it is 60–61% either way. **The
conclusion is robust to the error; the error is worth recording because it is a
fourth instance of a confidently-wrong number in this campaign's own reading.**

---

## 3. THE FUSION PRICED — four independent refutations

### 3.1 ρ multiplies the HOT working registers, not the cold store (the original category error, re-confirmed)

Pinnacle Eq. (22), fetched verbatim:
> "N = m + ρ Nw"

Pinnacle Eq. (25), fetched verbatim:
> "nm = 2n ⌈m/(w1 k)⌉ + ρ(ng + nb)"

**m — the input register, the cold store — appears exactly ONCE, not multiplied
by ρ.** ρ multiplies only the per-unit ports and the working registers, which are
operated on continuously and are therefore hot *by construction*. The yoked code
prices **idle** qubits. It contributes **exactly zero** to the marginal ρ cost.

Marginal cost of one extra working register, in Gidney's code:
```
kappa = f + 2l + len(m) + 2max(f, l+len(m)) + 1     (Pinnacle Eq. 23, verbatim)
      = 33 + 42 + 4 + 2(33) + 1 = 146 logical
146 * 1352 = 197,392 physical qubits per extra register
```
(The ledger recorded 206,856 = 153 x 1352. I get κ=146 from Gidney's own
Table-5 parameters; the ledger's 153 is not reproducible from Eq. 23. The ratio
197392/206856 = 0.954 accounts for the entire gap between my ρ=32 figure of
7.82x and the ledger's 14.06x being a *different quantity* — see §5. Neither
number is load-bearing; the sign is identical.)

Naive Gidney + ρ working registers:
```
rho= 1:    897,864  (1.00x)     rho= 8:  2,279,608  (2.54x)
rho=16:  3,858,744  (4.30x)     rho=32:  7,017,016  (7.82x)
```
**At ρ=32 the cold fraction collapses from 61% to 8%.** The parallelisation does
not exploit the cold store — it *consumes* the budget that the cold store occupied.
This is the exact opposite of the hypothesised fusion.

### 3.2 The enabling interface does not exist (re-confirmed from the yoked paper's own words)

Yoked surface codes, Discussion, **verbatim**:
> "In our previous format cold storage, logical qubits were stored as densely as possible, but could not be immediately operated upon. Operating on a logical qubit in cold storage requires first getting it out of storage. Concretely, this means the surface code patches don't all have access hallways available next to them."

> "it's blocked while a yoke is being measured"

Pinnacle requires, Sec. V.B.3, **verbatim**:
> "We allow for read-only memory access, which requires only gates that act as a control on the port and a target on the processing unit. This means that the access can be provided by using logical CNOT gates with controls on the logical qubits in a port and targets on ancillary logical qubits in the processing unit to fan out memory data onto the processing unit at the start of the access and fan in at the end of the access. Since such operations commute, arbitrarily many processing units can access the memory in parallel, provided they each have ports with measurement gadgets that can be used in parallel."

> "Since no entangling gates act within the memory, these ports can always be assumed to be separate from one another."

Pinnacle's *entire* parallelisation rests on ports that are (a) always
separated, (b) simultaneously live, and (c) attached to memory that is never
acted on within. A yoked cold patch has **no hallways** and is **blocked during
yoke measurement**. The two requirements are mutually exclusive.

Gidney himself flags this and leaves it open, p19, **verbatim**:
> "I'm a bit worried that the cold storage might get slightly worse during loop1 of the algorithm. During this loop, the yoke measurements would have to contend with Z-splitting copies of cold logical qubits to stream to hot storage to be used as the addresses of lookups. I'm confident 100K physical qubits is sufficient slack to ensure the streaming can be interleaved with the required yoke checks. I leave detailed analysis and simulations of cold storage, under various workloads, as future work."

He prices the risk as **unanalysed**. Neither paper analyses it.

### 3.3 Code-rate matching to ρ is a category error

The task asked whether "the yoked code's parameters [can] be chosen so the code
rate matches the parallelisation factor."

Yoked outer code, fetched verbatim:
> "we describe the stabilizers and observables of the [[64, 34, 4]] 2D parity check code in Table 1"

Outer rate k/n = 34/64 = **0.531**. ρ must reach |P| ~ 2.1 × 10^5 (see §6).
These are different quantities: the outer rate sets how many logical qubits
*live* per block, not how many can be *read concurrently*. The rate is O(1) and
ρ is O(10^2–10^5). **No rate match exists.** A yoked block with rate ρ would need
a block of size ~ρ, and its distance is 2^r in the block dimension — the
protection collapses long before the rate reaches ρ.

### 3.4 NEW, and decisive: Pinnacle's memory is 11.9x denser than the yoked store

This is the finding that was not in the ledger. Pinnacle Table I, fetched verbatim:
> "ncb = 2n", "npb = ncb + 4ng + 4nb"

| code | ncb=2n | k | phys/logical |
|---|---|---|---|
| J30,8,4K | 60 | 8 | 7.5 |
| J62,10,6K | 124 | 10 | 12.4 |
| J126,12,10K | 252 | 12 | 21.0 |
| J254,14,16K | 508 | 14 | **36.3** |

Pinnacle, Sec. V.B.3, **verbatim**:
> "we can encode 14ν logical qubits in memory such that ρ processing units can access it in parallel with 508ν + 88ρ physical qubits at d = 16"

```
Pinnacle memory   36.3 phys/logical
Gidney yoked cold 430   phys/logical   -> Pinnacle is 11.9x DENSER
Gidney hot patch  1352  phys/logical   -> Pinnacle is 37.3x DENSER
```

So:
- **Forward** (import yoked into Pinnacle's memory): the store gets **11.9x worse**.
- **Reverse** (import QLDPC into Gidney's cold store, which is 61% of his machine):
  ```
  ceil(1280/14) = 92 blocks x 508 = 46,736 physical  vs  Gidney's 550,400
  -> 8.5% of the cold store's cost; a saving of 503,664 physical qubits
  ```

**The yoked code is not the density winner. It wins only under a 2D-local
connectivity constraint that QLDPC codes violate.** The synthesis is not
"packaging" — it is *anti*-packaging.

**COMPARABILITY CAVEAT (load-bearing, and the honest limit of §3.4).** The two
regimes are NOT interchangeable on the same hardware, and I will not pretend
otherwise:
- Yoked, fetched verbatim: "Our construction assumes no additional connectivity
  beyond a nearest-neighbor square qubit grid operating at a physical error rate of 10−3."
- Pinnacle, fetched verbatim: "by relaxing the requirement of nearest-neighbour
  interactions, more general QLDPC codes can allow for many logical qubits to be
  encoded in a single code block."

So §3.4 does **not** refute Gidney — his 2D-local assumption is a deliberate,
reasonable hardware constraint. What it refutes is the **synthesis**: you cannot
have both the nearest-neighbour density and the QLDPC density on one device.
The gap in the ledger was asking for a fusion of two results whose advantage
comes from *mutually exclusive* hardware assumptions.

---

## 4. Sanity check against the Shor floor

ρ-parallelisation is a **time-for-space trade with no exponent change**:
Pinnacle Eq. (24), verbatim: "nw = ρ npb ⌈κ(f, ℓ, m)/k⌉ + nme" — space scales
linearly in ρ; Eq. (20)-(21) show time scales as T_G/ρ + O(log ρ). The product
is the Gidney spacetime volume. The 0.3 rT² form is untouched. **No claimed
classical assist reduces it, because there is no assist here.**

---

## 5. Reconciling my ρ=32 number with the ledger's 14.06x

The ledger recorded "7x at ρ=16, 14.06x at ρ=32". I get 4.30x and 7.82x. The
ratio is 1.037 and 1.042 — **exactly the κ ratio 153/146 = 1.048.** So the
disagreement is entirely which κ was substituted, not a modelling difference. I
could not reproduce κ=153 from Pinnacle Eq. 23 with Gidney's Table-5 parameters.
Reported honestly; **neither figure changes any verdict**, because both are ≫1
and the sign is the same.

---

## 6. One derived number, flagged

Pinnacle's "|P| ≈ 2.1 × 10^?" lost its **exponent at the pdftotext column
break** (confirmed in both `-layout` and raw modes; not recoverable from the PDF
byte stream). I did **not** guess it. Recovered from the paper's own constraint,
fetched verbatim: "the number of primes of bit length ℓ, π(ℓ) ≈ 2^(ℓ−1)/ℓ ln(2),
cannot be smaller than the number of primes |P|".

```
pi(21) ~  72,037   pi(22) ~ 137,525   pi(23) ~ 263,091   pi(24) ~ 504,258
2.1e5 is feasible for l in [23,24,25];  2.1e4 also feasible;  2.1e6 INFEASIBLE at any l<=25
```
Exponent = **5**, and it requires ℓ≥23, i.e. **not** Gidney's ℓ=21. Labelled
DERIVED, not fetched.

---

## 7. What actually survives (the one real open question)

**Narrow, and unchanged by this round:** can a yoked store support a
*non-destructive, concurrently shared* ρ-way read port, and at what cost?

What is now established, and was not:
1. The question is **only** about the input register (cold store). ρ-way
   concurrency on the *working* registers is irrelevant — those are hot.
2. A yoked **hot** storage format exists and is the only candidate — but it is
   priced at only ~2x density (Discussion, verbatim: "we estimate that yoked
   surface codes achieve nearly twice as many logical qubits per physical qubit
   as standard surface codes while keeping the logical qubits easily accessible
   during a computation"). Moving the input register cold→yoked-hot costs
   **+314,880 physical (+57.2%)**, total 897,864 → 1,212,744. It buys access,
   not density. **Refuted on space.**
3. The access has a **time** price too. Yoked Fig. 5, verbatim: "The total
   length of a syndrome cycle scales as 8 d × (# of blocks) + 2 d" (1D) and
   "25 d w + 4 d" (2D, w=8 → 5,100 rounds vs 25 for a bare patch). A yoked
   logical qubit cycles **66x–514x slower** than a surface-code patch.

**DECISIVE EXPERIMENT that would settle it** (none run; it is a simulation, and
I did not run one): measure the *outer-code* logical error rate of a single
yoked cold block under the exact load Gidney leaves open — periodic Z-split
streaming of w₁=6 qubits out of a block of nb=64 during loop1, with yoke
measurement contending. **Refuted if** the streamed qubits' logical error rate
exceeds 10⁻¹⁵ per round at the 100K-qubit slack Gidney assumes, or if the
contention forces the block count above the space already paid. **Confirmed if**
a yoked block sustains 10⁻¹⁵ while streaming 6 of 64 qubits per round. Gidney
explicitly leaves this as future work and **nobody has done it** — that is the
genuine, narrow, live gap. It is worth one paper, and it is worth far less than
the ledger's framing implied.

**Note the vacuity risk for whoever runs it:** a "success" here is a memory
reliability simulation, not a factoring result. It has no baseline to beat unless
the streaming load is varied against a no-streaming control at identical block
size — otherwise it is 100% pigeonhole, the r112 failure mode.

---

## 8. Files

- `gidney.pdf` / `gidney.txt` — arXiv:2505.15917v1, 4.2 MB, pdftotext -layout
- `pinnacle.pdf` / `pinnacle.txt` / `pinnacle_raw.txt` — arXiv:2602.11457v2, 1.2 MB
- `yoke_nc.html` / `yoke_nc.txt` — Nature Communications 16:4498, DOI 10.1038/s41467-025-59714-1
- `yoke_cr.json` — Crossref record (authors, date, journal)
- `resource_calc.py`, `fusion_price.py`, `rate_match.py`, `decisive.py`, `recover_P.py` — all with the positive control in §1
- Reproduce: `cd factor-scratch/r114/qrs && python3 rate_match.py && python3 decisive.py`

## 9. Honest summary

Eight of the recorded "gap" claims were re-derived from primary sources. The
61% is real. The three papers are real. But **the gap was an artefact of reading
abstracts**: Pinnacle cites Gidney as its reference [8], so the parallelisation
was already built on the paper containing the cold store. And the yoked code is
already banked in Gidney's baseline — cold storage *is* the yoked code, 61.30%
of the machine. There is no unexploited complementarity to harvest, and the one
direction that looks open (QLDPC memory) is closed by Pinnacle's own Table I.
**A rigorous kill. No positive manufactured.**
