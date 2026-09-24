import Mathlib.Data.Finset.Basic
import Mathlib.Data.Nat.Prime.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Negative results: factoring directions that are already closed

This file is a **kill record**.  A research catalog is most useful when it
remembers not only what was proved but also which plausible-looking directions
are *known dead*, so they are not re-proposed.  Each entry below was proposed,
then checked against the primary literature, and **killed**.  Most are
documentary; the machine-checked theorems at the end support entries 1, 7 and
11 (`mod4_not_injective`, `known_leak_maximized_at_balanced`,
`coldboot_noise_below_capacity`).  Entries 12–13 (the Berggren tree) rest on
theorems already proved in the `BerggrenModular` / `BerggrenSpectral` modules,
which are deliberately not re-imported here to keep this file self-contained.
Entries 14–17 (Gu–Martin) are documentary against arXiv:1709.02411; entry 17's
core fact ("a semiprime is squarefree") is elementary but is left documentary
because formalising it needs `Mathlib.Algebra.Squarefree.Basic`, which pulls in
`DecompositionMonoid ℕ` -- too heavy for this file's narrow-import discipline.
Entries 19-20 (noisy-key list decoding) are documentary against PPS
(ePrint 2012/724), Heninger--Shacham and Henecka--May--Meurer.

State of the art (as of late 2026): the general number field sieve at
`L[1/3, (64/9)^{1/3} ≈ 1.923]` is unchanged, ECM at `L_p[1/2, √2]`, and there is
no polynomial-time classical general-purpose factoring algorithm.  Harvey's
deterministic `N^{1/5}` (Math. Comp. 2021) is rigorous but deterministic and
exponential, so it does not touch RSA security.  References:
Buhler–Lenstra–Pomerance 1993; Harvey 2020; Barbulescu–Guillevic–Lenstra–Razvan
(ePrint 2020/829).

## The killed directions

| # | Proposed direction | Why it is dead | Reference |
|---|--------------------|----------------|-----------|
| 1 | **Reciprocal / Gauss-sum phase** — read the factor off `arg` of a quadratic Gauss sum mod `N`. | The phase of the genuine Gauss sums is a 4th root of unity fixed by `N mod 4` and small residue symbols (polynomial time), carrying **zero** bits about `p`, `q`. The proposed double twist is not even multiplicative. | Murty, *Evaluation of the Quadratic Gauss Sum* |
| 2 | **Self-similar / "unbounded arity" sieve tower** — beat the `L[1/k,c]` barrier with `k = π(B)`. | It is Schirokauer's **Tower NFS** (2000) + special-`q` descent; even for arbitrary extension degree the complexity is still `L[1/3, (64/9)^{1/3}]`. The "polynomial escape" omits the Dickman factor `1/ρ(u)`: for `k = π(B)` the true relation-collection cost is `≈ √N`. | Schirokauer 2000; Barbulescu–Gaudry–Kleinjung, *The Tower NFS* (ePrint 2015/505) |
| 3 | **Real-quadratic infrastructure / CF-period parity** — one parity bit of the period of `√N` as a factor oracle. | The parity theorem is **Lagrange/Legendre** (1760s–1785), a *negative-Pell solvability* criterion, not a factoring oracle. On RSA semiprimes the bit is free or uninformative, and one bit cannot factor an `n`-bit modulus. The `N^{1/4}` partial step is **SQUFOF** (Shanks 1969). The BSGS fast path needs the regulator, and factoring reduces to computing the regulator. | Rippon–Taylor 2004; Gower–Wagstaff 2008; Bernstein (parallel SQUFOF); Murru–Salvatori 2024 |
| 4 | **Precomputation-amortized factoring** — a universal factor base / batched sieve to break the exponent. | Amortization moves only the **constant `c`** (GNFS `1.923` → Coppersmith factory `1.639`), never the exponent `ρ = 1/3`. Practical realizable gains are `≈ 2×` (Mersenne factory). | Bernstein–Lange, *Batch NFS* (2014/921); Kleinjung–Bos–Lenstra, *Mersenne Factorization Factory* (2014/653) |
| 5 | **Genus-character single-bit reduction** — factor `N` from one nonprincipal quadratic character. | The content is Gauss's genus theory (1801); the one-character formulation is folklore-grade repackaging, and its formalizable core `(a/p)(a/q) = (a/pq)` is a one-line Mathlib lemma. | Gauss, *Disquisitiones Arithmeticae* 1801; Cox, *Primes of the Form x²+ny²* |
| 6 | **"AGM conjecture" as a witness that `n/4` is optimal** — cite a named conjecture to certify the partial-key barrier. | **A phantom citation.** Attributed variously to Alvarez–Gruber–Maier and to a Coppersmith–Howgrave–Graham–Unger CRYPTO 2004 paper, it has zero trace on Google Scholar, Crossref, the arXiv API, or a full IACR cryptodb sweep (≈1800 records, 1996–2007); the "AGM conjecture" hits that exist are the *symmetrized arithmetic–geometric mean inequality* in operator theory. Use the **proved** bounds instead: `X ≤ N^{β²}` (ePrint 2022/271, Thm 2) and `γ₁+…+γ_n < β²` (ePrint 2014/343, Thm 7). | see `RESEARCH.md` §4d-v |
| 7 | **"`1/3` of the bits of `p` factors RSA"** — a sub-`n/4` partial-key crossing. | The claim comes from Takayasu–Kunihiro's asymptotic PKE curve and was **refuted by the very paper that introduced the `1/3`**: May–Nowakowski–Sarkar show the claim would be "a major improvement over Coppersmith's famous factoring with hint", then give "strong experimental evidence that TK fails". Separately, the MNS "1/3" itself is a leak of the **CRT exponents `d_p,d_q`**, not of `p` — absolute known-bit budget is still `N^{1/4}`. | Takayasu–Kunihiro ePrint 2016/1056, 2018/516; May–Nowakowski–Sarkar ePrint 2022/271 §1, §5 |
| 8 | **Memcomputing / self-organizing-gate factoring** — an *attractor-based, chaos-avoiding* analog device, so noise cannot corrupt a contracting orbit. | **Killed by its own follow-up.** The headline "sub-second 2048-bit" is a **low-degree polynomial extrapolation** from a tuned ≤300-bit range; the largest actual *run* is ~60 bits and there is no silicon. Nguyen et al. show the contraction the design relies on is **destroyed by noise**, so "attracting ⇒ robust ⇒ large `N`" fails in-model. | Sharp et al. arXiv:2309.08198; Nguyen et al. arXiv:2506.14928 (*Chaos* 2026) |
| 9 | **Resonance / peak-position factor encoding** — read `p` off a resonance whose position encodes the divisor. | **Two independent kills.** (i) *Continuity:* factoring is **discontinuous** — adjacent `N` have wildly different factors — so **no smooth flow can output `p(N)` continuously**; there is no continuous resonance to position-encode. (ii) *Reduction:* the discrete-instantiation is the already-dead **RSDT** mechanism, which collapses to trial division. | see `RESEARCH.md` §4a |
| 10 | **"Noisy Coppersmith"** — a rigorous noise-tolerant form of `X ≤ N^{β²}`, e.g. `X ≤ f(N,e)` for `e` errors in the known bits of `p`. | **A category error: no attack ever feeds noisy bits to the lattice.** Halderman et al. (CCS 2008 §5.4) and Paterson–Polychroniadou–Sibborn (ASIACRYPT 2012 §2) *both* branch bit-by-bit first and invoke Coppersmith only on **clean, already-recovered** bits — it is a final step, never the noise-robust one. The multivariate ACD-with-error extension is **heuristic on its face** (Cohn–Heninger, ePrint 2011/437: "we cannot rigorously prove that it always works"). | see `RESEARCH.md` §4e |
| 11 | **"Noise *rate* is what makes cold-boot RSA hard"** — the premise of the old noisy-leak framing. | **Backwards: the noise rate is in *surplus*.** Real remanence decay leaves **≥90% of bits correct** (Halderman measured `δ` = 4–10%), far cleaner than the ~20–24% error the whole-key methods can barely handle — see `coldboot_noise_below_capacity` below. The genuine difficulty is the **channel asymmetry** (unidirectional 1→0 decay), on which HS/HMM **fail outright**; only PPS's maximum-likelihood decoder works. | see `RESEARCH.md` §4e |
| 12 | **The Berggren / Pythagorean triplet tree as a factoring device** — the tree is exponentially large (`3^k` states) and variable-depth, which looked like an escape from the fixed-construction barriers. | ⚠️ **[KILL REASON CORRECTED 2026-09-24 — the original reason here was FALSE.]** This row used to say the tree's "control word, nodes and continuous invariants carry **zero bits** about `p`". That is **refuted**: for the Fermat pair the node's ratio `r = m/n` satisfies `p² = N(r−1)/(r+1)`, so `r` is a *sufficient statistic* for `p` (`FactorEncodingAudit.lean`, machine-checked). The correct kill is **circularity, not bit-counting**: *reading* the word needs `p` to know the node, and *computing* it from `N` is factoring in disguise (the band-`A` descent is literally `(p,q) ↦ (p, q−2p)`). Independently, the tree is **Farey-limited, not `3^t`-limited** — only `B`-steps narrow a cylinder, the depth-`t` cylinders overlap, and the fitted search cost is `3^{d(p)} ≈ p^{1.00}`, no better than trial division and `p^{0.5}` worse than Pollard `ρ`. A cheap *trivial* Fermat node exists for every odd `N` (`m − n = 1`), so "produce a node" factors nothing. | `RESEARCH.md` §4f, §4f-ii; `FactorEncodingAudit.lean` |
| 13 | **Berggren spectral resonance as a new factoring method** (`berg_resonance_factorization`, `M₂` powers mod `p`). | **It is Pollard `p±1`.** `berg_two_resonance_mod_eight` proves `ord_p(M₂) ∣ p ∓ 1` (sign by `p mod 8`), so the sweep `gcd(M₂^k − 1, N)` splits `N` exactly when `p ∓ 1` is `B`-smooth — the Chevalley–Wielandt matrix form of `p+1`, with base `M₂`. `L[1/2]`-class, **dominated by the NFS**. Upgrades the catalog's older "circular" verdict to "circular *and* classically dominated." | `BerggrenSpectral/HyperbolicResonance.lean`, theorem `berg_two_resonance_mod_eight` |
| 14 | **Aim the modular-curve route at the Hecke *newform* count `B(k,N)` instead of the automorphic count `A(k,N)`** — `B` is the more "concrete" of the two. | **A fast `B` buys nothing for factoring.** `H(k,N) = G(k,N) − B(k,1)` is also factorization-free, and `H(k,N) = B(k,N)` **iff `N` is prime** (Gu–Martin Cor. 9, `N ≥ 92`) — so fast `B` is a **primality test**, already in `P` via AKS/ECPP. The factoring reduction is **`A`-specific**: Thm. 10 needs **two `A`-values plus one `B`-value**, not `B` alone. | Gu–Martin arXiv:1709.02411, Cor. 9, Thm. 10; `RESEARCH.md` §4c-iii |
| 15 | **Tune the weight `k` of the modular-curve count to dodge the factorization** — larger `k` might dilute the index term. | **`k` is irrelevant, and `k = 2` is the worst case.** The multiplicative core `s*₀(N)`, `ν*∞(N)`, `ν*₂(N)`, `ν*₃(N)` — exactly where the factorization lives — is **`k`-independent**; `k` enters only the constants `c₂(k)` (period 4) and `c₃(k)` (period 3). Gu–Martin accept **any** positive even `k` (Cor. 4 for `N ≥ 10`; Thm. 8 / Cor. 9 for `N ≥ 92`). Worse, the main term is `(k−1)N/12 · s*₀(N)`, so **larger `k` is more dominated** by the factorization-encoding index; the exception lists (Cor. 31's nine `(k,p)` pairs) show small `k` is where the closed forms degenerate. | Gu–Martin arXiv:1709.02411, Props. 15/29; `RESEARCH.md` §4c-iii |
| 16 | **"A cheap *Oesterlé* upper bound on `g(X₀(N))` would feed Cor. 4."** | **Dead on citation, and the soft target is real.** The only thing called the Oesterlé bound in circulation is the **Ihara–Oesterlé (Weil–Oesterlé) *point-count* bound** on `#C(ℱ_q)` in terms of genus — a *different object*. **No factorization-free upper bound on `g(X₀(N))` exists.** Three related phantoms: "Cremona–Odoni, *Some remarks on the Oesterlé bound*, IJM 5 (1994) 147–154" (those pages belong to a Ye article, DOI `10.1142/s0129167x94000073`); "Cremona–Odoni, *Computing the genus of `X₀(N)`*"; "Cremona, *Algorithmic invariants for elliptic curves*" (his book is *Algorithms for modular elliptic curves*, CUP 1992). "Oesterlé, Invent. Math. 73 (1983) 273–302" is **uncorroborated**; use **Cohen–Oesterlé, LNM 627 (1977) 69–78**, which is what Sage actually implements. | `RESEARCH.md` §4c-iii; Sage `sage.modular.dims` docs |
| 17 | **Use Gu–Martin's squarefreeness test (Cor. 4) to break RSA** — `A = G` iff `N` is squarefree, so a fast count decides it. | **Tautological on a semiprime.** `N = pq` with `p ≠ q` prime is **squarefree by definition**, so the test returns "squarefree" with no computation and yields **zero** bits about `p`. *(Elementary, and left documentary: formalising it needs `Mathlib.Algebra.Squarefree.Basic`, which drags in `DecompositionMonoid ℕ` — too heavy for this file's narrow-import discipline.)* Cor. 4 is the right statement of the *general* obstruction and is why Gu–Martin, who treat arbitrary `N`, lead with it — but for RSA the squarefull part is `D = 1`, `φ(D)` is trivial, and the real signal is the multiplicative term `s*₀(N)` (which encodes `ω(N)`), reached through the **two-weight linear system**, not through squarefreeness. | `RESEARCH.md` §4c-iii; Gu–Martin arXiv:1709.02411 Cor. 4 |
| 18 | **Apply the Allender–Saks–Schparlinski parity-of-`ω` `AC⁰[p]` lower-bound technique to `Ω` (prime factors counted *with* multiplicity)** — this survey's own recommended circuit-lower-bound target, `Ω ∉ uniform TC⁰`. | **The one published technique provably does not transfer, and the target is also unlinked to factoring.** The ASS reduction reads `Mod_p(x) = 0 ⟺ ω(x)+1 ≡ ω(px) (mod 2)`, so the parity oracle on `{x, px}` **flips iff `p ∣ x`**. For `Ω` the increment is `Ω(px) = Ω(x) + 1` **unconditionally** (`p` prime), so the parity oracle is **constant** on `{x, px}` and recovers nothing about `p ∣ x`. Separately, the link to factoring is **believed, not proven**: Du & Volkovich (FSTTCS 2021) say so in as many words and **no poly-time reduction in either direction between `FACTOR` and `Ω` is known**, so `Ω ∉ TC⁰` would not be a factoring lower bound. **Corrected target: `spf(N) ∉ DLOGTIME-uniform TC⁰`**, which is `≡ₚ FACTOR` by definition. | ASS, *A Lower Bound for Primality*, CCC 1999, DOI `10.1109/CCC.1999.766257`; Du & Volkovich, FSTTCS 2021, DOI `10.4230/LIPIcs.FSTTCS.2021.17`; `RESEARCH.md` §8.4 |
| 19 | **Model the RSA private key as a Reed–Solomon code over `GF(2^m)`, and take the "code" to be the set of valid keys for a fixed `N`.** | **Both halves are wrong.** (i) There is **no Reed–Solomon anywhere in this literature** — grep-verified zero occurrences in Heninger–Shacham (CRYPTO 2009), Henecka–May–Meurer (CRYPTO 2010) or Paterson–Polychroniadou–Sibborn (ASIACRYPT 2012). The channel is **bit-level** (BSC / Z-channel) and the code is **binary**; grouping bits into `m`-bit symbols does not create a q-ary symbol channel. (ii) For fixed `N` there is **exactly one** valid key (unique factorization), so that set is a **rate-0 singleton** and "list-decoding" it is just guessing the key — i.e. factoring. The real code is **the algorithm's candidate set**: `2^t` words of `5t` bits forming a Hensel/2-adic-lifting **tree** forest, rate `1/5`. (Related phantom: "Heninger–Shacham–Heninger" is not an author triple; CRYPTO 2010 is Henecka–May–Meurer.) | `RESEARCH.md` §4e-i; Heninger–Shacham DOI `10.1007/978-3-642-03356-8_1`; Henecka–May–Meurer DOI `10.1007/978-3-642-14623-7_19`; PPS DOI `10.1007/978-3-642-34961-4_24` |
| 20 | **"The random-code assumption is the load-bearing open question — the RSA key is probably not a good code for list decoding, and justifying it would yield an RSA-specific noise limit."** | **Answered, and the premise was backwards.** At rate `1/5` PPS **prove** the ceilings `δ ≤ 0.243` (BSC) and `β ≤ 0.666` (Z-channel); the achieved thresholds (`0.237` heuristic, `0.20–0.23` experimental) sit just under them, so the model is **near-tight**. Meanwhile the **random-code model UNDER-predicts by 2.4×**: a random rate-`1/5` code has Johnson radius `½ − √(R(1−R)) = 0.100`, against `0.237` achieved. Reason: **the code is a TREE code, and tree codes list-decode toward capacity** while random codes stall at the Johnson radius. So the RSA key tuple **is** a good code for list decoding. **The open residue is two items, neither RSA-specific:** (i) justify the tree's weak-randomness/decorrelation assumption (`k ≈ 5`, empirical); (ii) a **random-coding bound for list decoding on the asymmetric channel** — a *coding-theory* gap PPS flagged in 2012 and which a 2013–2026 sweep found unclosed. ⚠️ And `0.2786` is a **phantom number** — absent from every primary source; the real rate-`1/5` figures are `0.243` and `0.666`. | `RESEARCH.md` §4e-i; PPS, ASIACRYPT 2012, ePrint 2012/724, DOI `10.1007/978-3-642-34961-4_24`; Elias IEEE-IT DOI `10.1109/18.61123`; Guruswami DOI `10.1561/9781601980052` |
| 21 | **Read the factorization off a fixed class group, or off any fixed arithmetic structure** — a fixed class group `Cl(K)`, a fixed reduced form of fixed discriminant, the Berggren tree, or the tree's fixed Hecke algebra. | **Information-theoretic, and the cleanest form of the meta-barrier.** A handle that recovers `p` must be **injective** on the `n`-bit semiprimes `S_n = { N = pq : 2^{n−1} < N < 2^n }` (since `p` determines `N`, and `N` determines `p = spf(N)`), so by Landau it needs `log₂\|S_n\| = n − Θ(log n)` bits of range; a *fixed* structure has `O(1)` (`h(K)` is a constant). Pigeonhole ⇒ contradiction. **No `P ≠ NP`, no GRH, no subexponential assumption** — the obstruction is range size, not computability. ⚠️ **[COUNTING SET REPAIRED 2026-09-24 — the earlier wording here and in §5b was degenerate and the proof vacuous as printed.]** It read *"injective on the candidate factors (`≈ 2^{n/2}/n` of them)"*; but `N` is fixed, so the candidate factors are the **divisors of one `N`**, only `O(n)` of them, and the handle never needs to separate them at all — the injectivity that matters is **across moduli**, which is the `S_n` above. The repair **doubles** the required range (`n − Θ(log n)`, not `n/2 − Θ(log n)`) and so strengthens the kill. The `N`-dependent escapes are also closed: imaginary `Cl(ℚ(√(−pq)))` has 2-torsion forced to `C₂` (**zero bits**) with the rest reachable only subexponentially (Hafner–McCurley, `L[1/2,√2]`, which does not beat `L[1/3,1.923]`); real `h(ℚ(√(pq)))` needs the **regulator** = a Pell solution = the full `Θ(√N)` CF period, so it is **vacuous**. *One-directional hardness only; the converse is not claimed.* `2^{n/2}/n` was **NEVER a sound requirement**; treat any surviving use of it as an error. | `RESEARCH.md` §5b; `FactorEncodingAudit.lean` (`fixed_range_cannot_be_injective`); Mosunov–Jacobson arXiv:1502.07953; Hafner–McCurley JAMS 2(4):837–850 1989 |
| 22 | **Pell / Størmer / consecutive-smooth factoring** — write `p = a u²`, `q = b v²` with `a,b` squarefree and `B`-smooth, then solve a Pell equation in `ℚ(√{ab})`. | **The prime set is the input, and the input is the secret.** Størmer–Lehmer takes `B` as input, and `ab` is computable **iff `N` is already factored** — the only Pell node fixed by `N` alone is the trivial `(1,0)`, discriminant `1`. Unlike the Fermat case there is **no cheap non-trivial rescue node**. *And even granted `a,b`:* cost `Θ(2^{π(B)}·N^{1/2})`, worse than `ρ` (`N^{1/4}`), Lehman (`N^{1/3}`) and Harvey (`N^{1/5}`) for every `B`; and RSA primes are not `B`-smooth for any usable `B`. The `D=2` variant asks for largest-prime-factor bounds on Lucas terms — unconditionally only `P(L_n) > (1/86)·log log n`, and under `abc` the terms are **not** smooth. ⚠️ The "Sanna smooth-values" citation is a **MISCITATION** (no such paper; his real work characterises `p ≡ ±1 mod ρ`, i.e. the `p±1` route). | `RESEARCH.md` §5d; Batte–Luca 2024 (Crossref-verified) |
| 23 | **Tree-order search of the Berggren tree as a factoring handle** — exploit `3^k` branching to reach the node encoding `p` faster than `√p`. | **The branching is spent on redundancy, not coverage.** Only `B`-steps narrow a cylinder and even `B` shrinks a prefix by just `≈0.91–0.99` per letter; `A` never narrows (fixed interval `(1,2)`), `C` gives half-lines. The depth-`t` cylinders **overlap in a bounded interval** (total width *grows* `≈2.4^t`; median width stays `≈0.67` at `t=7`). Effective sample size is **Farey-limited** (primitive count `≈0.524·X`), one level buys `1.20` bits not `log₂3`. Fitted cost `3^{d(p)} ≈ p^{1.00}` — **no better than trial division, `p^{0.5}` worse than Pollard `ρ`**. Mod-`p` residues are uniform (`χ²/df ≈ 1.0`), so no horocycle statistic separates `p` from `q`. | `RESEARCH.md` §4f-ii |
| 24 | **A short "moment quotient" of the matrix orbit mod `N`** — a low-order Hecke/moment correlate that would leak `p` via a period of `3` or `9`. | **Exponential, and the naive test is the wrong test.** Moments *do* collapse `ord(M₂ mod N)` (measured 236 billion at `N=697`) to the `lcm` of the **eigenvalue** orders `ord(3+2√2 mod p)` — but that order grows **linearly in `p`** (medians 8768 / 23164 / 49692 over `p`-bands of median 40k / 100k / 220k, `≈ p/4`) and its absolute minimum over `p ≤ 300 000` never collapses to a constant (smallest 42, 54, 38). So the moment period is `Θ(N)`, **exponential in the input size**; `3` and `9` are decisively falsified. Confirmed exactly: period `40 = lcm(8,20)` at `N=697`, `528 = lcm(44,48)` at `N=8633`. *(`PROVED` for the period formula; `EMPIRICAL` for the generic growth.)* | `RESEARCH.md` §4f-ii |
| 25 | **"Diagonalizing `M₂` over `ℤ/Nℤ` is a factoring handle"** — the 16-fold root degeneracy in `R_N = (ℤ/N)[t]/(t²−2)` suggests one `gcd` of a root's constant coordinate gives `p`. | **A quantifier error, adjudicated 2026-09-24.** The *canonical* root `t` (the generator, `a=0`) **is** a valid root and **does** diagonalise `M₂` — eigenvectors `(1,1,t)`, `(1,1,−t)`, `(1,−1,0)`, unit change of basis. So `DIAG` has a **deterministic `O(1)` total solver that always yields `gcd(0,N)=N`**. The optimistic argument showed `E[factor | uniformly random root] = 1/2`; a reduction must succeed on **every** valid output, and the canonical root is a valid counterexample. **Verdict: `DIAG ∈ P`, so `DIAG ⇏ FACTOR`** — the real content is the second-root / square-root-**oracle** reduction (an oracle over arbitrary residues factors; one *instance* of a known residue does not). Reaching a leaking root is not a shortcut: 0 hits in 2M random samples. *Related, and settled in the opposite direction:* DLP/order-finding mod a composite is **randomly equivalent to factoring** (Long; Bach–Miller–Shallit 1986), so it is *harder than* factoring, not a handle for it. | `RESEARCH.md` §4f-ii; Bühler & Crandall, *Basic Algorithms in Number Theory* ch. 2; Bach–Miller–Shallit DOI `10.1137/0215083` |
| 26 | **The ℓ-adic skeleton of the Fermat node as a close-prime detector** — for the node `(m,n) = ((q+p)/2, (q−p)/2)`, read the flag `(ℓ ∣ m, ℓ ∣ n)` or the level `S_ℓ = (v_ℓ(m), v_ℓ(n))` and use a high level as a proxy for `p, q` being close. | **REFUTED on the direction, which is the decisive defect; the residue count is a secondary kill.** `v₂(gap) = j` means `2ʲ ∣ gap`, hence `gap ≥ 2ʲ` — a *higher* 2-adic level certifies a *larger* gap, so the statistic is **monotonically anti-correlated with closeness**. Machine-checked: `two_pow_dvd_gap_implies_gap_ge` in `LadicFlag.lean`. This argument is residue-free and level-free, so sealing more congruences cannot repair it. *Secondary:* the only sealed 2-adic fact is a parity bit already visible in `N mod 4`, i.e. `4 ∣ (pq−1) ↔ 4 ∣ (q−p)` (`four_dvd_pq_sub_one_iff_four_dvd_q_sub_p`, same file) — zero size information. *And ℓ ≥ 5 is not sealed anyway:* bucketing all `35 553` odd semiprime Fermat nodes (`N ≤ 2·10⁵`) by `N mod ℓ^k`, the flag is unsealed at `k = 1,2,3` for every prime `ℓ ∈ [5,37]` tested. ⚠️ **This unsealed-ness is an EMPIRICAL finding, not a theorem**, and its honest scope is "unsealed wherever the test has power": at `k = 4`, `ℓ ≥ 19` gives `ℓʲ ≈ 19⁴ = 130321` against a `2·10⁵` bound, so every bucket is a **singleton** and "sealed" there is a powerless test, not a result. *The sufficient reason, which subsumes all of the above:* the skeleton is a **function of `N mod ℓ^k`**, computable from `N` in `O(1)`, so it is a recomputable function of **public input** — §5b's uniformity kill in a concrete instance. Reading it returns `N` to itself, and no ℓ-adic budget (whether `O(log log N)` or a constant) rescues that. | `RESEARCH.md` §4f-iii; `Catalog/Cryptography/Berggren3Adic/LadicFlag.lean`; `Skeleton.lean`; `NegativeResults.lean` (`mod4_not_injective`) |

## The `n/4` partial-key barrier, and where the square comes from

For a factor `p ≈ N^β` the **proved** univariate bound is `X ≤ N^{β²}`: `n/4`
bits of a balanced modulus is *half* of `p`'s bits, not a quarter.  The exponent
is not monomial-counting and not root-counting over `F_p` — the polynomial is
univariate, so lattice rank is independent of degree.  It is the
**determinant-vs-modulus enabling condition** on the shift-polynomial lattice:
the `N^{max(0,t−i)}` factors buy vanishing modulus `N^{βm²}` but cost
`N^{β²m²/2}` in the determinant, and the ratio `t²/(m(m+1)) → β²` is the whole
exponent.  The theorem `known_leak_maximized_at_balanced` below machine-checks the
consequence: the required leakage `(β − β²)n` is **maximized at `β = 1/2`**,
where it equals `n/4`.  Balance is exactly what makes the barrier worst.

⚠️ **[Corrected 2026-09-24 — this paragraph's *mechanism* is fine, but
`RESEARCH.md` §4d-ii's *derivation* of the square was broken and has been
repaired; the two files must not be read as agreeing on a derivation.]**  §4d-ii
used to close with `p ≤ N`, giving `N^{2β−β²} ≤ N^{β²}` — i.e. `β ≤ β²`, false
for every `0 < β < 1` (at `β=½` it asserts `N^{3/4} ≤ N^{1/4}`).  The step needed
is `p ≤ √N`, which yields `X ≤ N^{β−β²}`.  **The `n/4` wall is unaffected**:
`β − β²` is maximised at `β = ½`, and the required-known-bits budget above is the
*same* quantity — so the corrected derivation and the leakage budget agree, and
that agreement is the cleanest available statement of the wall.  Note the
consequence: the shift-lattice argument as written delivers `β − β²`, which is
the *weaker* of the two exponents for `0 < β < ½`; the sharper `X ≤ N^{β²}` is a
literature input (ePrint 2022/271 Thm 2), **not** a consequence of this
derivation.  `FactorEncodingAudit.lean` machine-checks the correction:
`fourdii_printed_step_false`, `strict_gap_below_half`, `beta_sq_le_gap`, and
`corrected_exponent_maximized_at_balanced`.

## Why the "arity" escape is an artifact — the load-bearing correction

The `1/3` exponent of the NFS is **not** an AM–GM balance over three stages.  It
is the optimum of a smoothness-probability vs. linear-algebra balance
(minimise `B² + E²` subject to `E² · Prob ≥ B^{1+o(1)}`), which is **insensitive
to arity**.  `tradeoff_lower_bound` in `TradeoffBarrier.lean` is a correct AM–GM
theorem *about its model*, but that model omits the Dickman smoothness factor
and must not be read as a lower bound on factoring.  This is the correction that
direction 2 turns on.
-/

namespace FactoringBarriers.NegativeResults

/-- `n` is a product of two distinct primes.  (A self-contained copy so this
record does not depend on the `Pythagorean` factoring-barrier module.) -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p ≠ q ∧ n = p * q

/-- Three distinct semiprimes, all congruent to `3 (mod 4)`.  They are pairwise
distinguished, but *not* by the residue class — the point of the theorem below. -/
def mod4Semiprimes : Finset ℕ := {15, 39, 55}

/-- Every member of `mod4Semiprimes` is a product of two distinct primes. -/
theorem mem_mod4Semiprimes_isSemiprime {n : ℕ} (h : n ∈ mod4Semiprimes) :
    IsSemiprime n := by
  simp only [mod4Semiprimes, Finset.mem_insert, Finset.mem_singleton] at h
  rcases h with rfl | rfl | rfl
  · exact ⟨3, 5, by decide, by decide, by decide, rfl⟩
  · exact ⟨3, 13, by decide, by decide, by decide, rfl⟩
  · exact ⟨5, 11, by decide, by decide, by decide, rfl⟩

/-- **A low-order residue observable carries no factoring information.**  The
map `n ↦ n mod 4` is not injective on the semiprimes: `15 = 3·5` and
`39 = 3·13` are distinct factorisations of distinct moduli, yet share a residue
class.

This is the machine-checked core of killed direction #1.  The phase of a
quadratic Gauss sum is a 4th root of unity fixed by `N mod 4` (and small residue
symbols such as `(2/N)`), so it — like `n mod 4` — cannot separate distinct
factorisations.  The general information-theoretic form is stronger still: the
number of semiprimes up to `N` is exponential in `log N`, so *no* single-bit
classical oracle can factor. -/
theorem mod4_not_injective : ¬ Function.Injective (fun n : ℕ => n % 4) := by
  intro h
  have heq : (15 : ℕ) % 4 = 39 % 4 := by norm_num
  have h1521 : (15 : ℕ) = 39 := h heq
  norm_num at h1521

/-- **The partial-key leakage requirement is maximised at the balanced modulus.**
For a factor `p ≈ N^β` the proved univariate bound `X ≤ N^{β²}` requires
`(β − β²)n` *known* bits, and this is at most `n/4`, with equality exactly at
`β = 1/2`.

The content is the completed square `4(β − β²) = 1 − (2β − 1)² ≤ 1`, i.e.
`β − β² ≤ 1/4` because `(2β − 1)² ≥ 0`.  So the `n/4` barrier is a statement
about the **balanced** case specifically: every `β < 1/2` (an unbalanced `N`)
needs *strictly* fewer than `n/4` bits.  This is the machine-checked core of
`RESEARCH.md` §4d-iii — balance is what maximises the required leakage, which is
why the balanced RSA modulus is the worst case. -/
theorem known_leak_maximized_at_balanced (β : ℝ) (n : ℝ) (hn : 0 ≤ n) :
    (β - β * β) * n ≤ n / 4 := by
  have hsq : 0 ≤ (2 * β - 1) ^ 2 := sq_nonneg (2 * β - 1)
  nlinarith

/-- The bound is **attained** at the balanced modulus `β = 1/2`: there the
required leakage is exactly `n/4`. -/
theorem known_leak_attained_at_balanced (n : ℝ) : ((1 / 2 : ℝ) - (1 / 2 : ℝ) ^ 2) * n = n / 4 := by
  ring

/-- **Real cold-boot noise is in surplus, not scarce** — the arithmetic that
kills killed direction #11.

Halderman et al. measured remanence decay on real hardware at `δ ≤ 1/10` for
RSA (2048-bit keys: `δ = 4%` and `6%`; 512-bit primes: `δ = 10%`), leaving at
least `9/10` of the key bits correct.  The whole-key erasure recovery of
Heninger–Shacham needs only `1/5` of the bits known — the capacity figure is
`0.20` (their heuristic analysis claims `0.27`, the formal threshold
`2 − 2^{4/5} ≈ 0.2589`; take the most conservative, `1/5`).

So the observed clean fraction *strictly exceeds* the fraction the best
whole-key method needs to have known.  The noise rate is therefore **not** the
binding constraint on cold-boot RSA recovery: the binding constraints are the
leak *amount* and the channel *asymmetry*.  This is the numeric core of
`RESEARCH.md` §4e's second kill. -/
theorem coldboot_noise_below_capacity : (1 : ℝ) - 1 / 10 > 1 / 5 := by
  norm_num

end FactoringBarriers.NegativeResults
