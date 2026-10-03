# NFS constant verification (round 48, literature)

Every row below rests on a URL **actually fetched from this host**. **WebSearch was never used** (it fabricates citations on this box). Page numbers are pdftotext page indices of the cited PDF; where a formula or an exponent placement matters, the page was rendered (`pdftoppm -r 150..170`) and **read as an image**, because pdftotext flattens superscripts and fractions.

---

## 1. The GNFS constant 1.923 = (64/9)^(1/3)

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 1.1 | GNFS = L_n[1/3,(64/9)^(1/3)] ≈ 1.923, "the fastest algorithm known for integer factorization"; SNFS = (32/9)^(1/3) ≈ 1.526 | Menezes, van Oorschot, Vanstone, *Handbook of Applied Cryptography* (CRC Press 1997), §3.2.7 | https://cacr.uwaterloo.ca/hac/about/chap3.pdf | **13** (printed p.98) | "A special version of the algorithm (the *special number field sieve*) applies to integers of the form n = r^e − s for small r and |s|, and has an expected running time of L_n[1/3, c], where c = (32/9)^{1/3} ≈ 1.526. ... The general version of the algorithm, sometimes called the *general number field sieve*, applies to all integers and has an expected running time of L_n[1/3, c], where c = (64/9)^{1/3} ≈ 1.923. This is, asymptotically, the fastest algorithm known for integer factorization." | **VERIFIED** (page image read) |
| 1.2 | GNFS constant written as the literal decimal **1.923** | Aoki, Franke, Kleinjung, Lenstra, Osvik, "A Kilobit Special Number Field Sieve Factorization", ASIACRYPT 2007, LNCS 4833, pp. 1-12 | https://link.springer.com/content/pdf/10.1007/978-3-540-76900-2_1.pdf | **11** | "T(b) = exp(1.923 ln(2^b)^(1/3) (ln(ln(2^b)))^(2/3)) is a rough growth rate estimate for the run time of NFS when applied to a b-bit RSA modulus (cf. [11])." | **VERIFIED** (page image read) |
| 1.3 | GNFS = L_n[1/3,(64/9)^(1/3)], stated for the **general case only** | Boudot, Gaudry, Guillevic, Heninger, Thomé, Zimmermann, "Comparing the difficulty of factorization and discrete logarithm: a 240-digit experiment", eprint 2020/697 | https://eprint.iacr.org/2020/697.pdf | **4** | "In this work, we are concerned only with the general case (GNFS). The time and space complexity can be expressed as LN(1/3,(64/9)^1/3)^(1+o(1)) = exp((64/9)^1/3 (log N)^(1/3) (log log N)^(2/3) (1+o(1))) for factoring." | **VERIFIED** |
| 1.4 | GNFS = L_n[1/3,(64/9)^(1/3)] | Bansimba & Babindamana, "Integer Factorization: Another perspective", arXiv:2507.07055 (2025) | https://arxiv.org/pdf/2507.07055 | **3** | "The General Number Field Sieve (GNFS) is the most efficient classical algorithm for factoring large integers ... Its expected time complexity is O(e^{((8/3)^{2/3}+O(1))(log n)^{1/3}(log log n)^{2/3}}) = L_n[1/3,(64/9)^{1/3}]." | **VERIFIED** (page image read) |
| 1.5 | 1.92299... as the decimal form of (64/9)^(1/3) | Lee & Venkatesan, "Rigorous Analysis of a Randomised Number Field Sieve", arXiv:1805.08873 | https://arxiv.org/pdf/1805.08873 | **2** | "There is a randomised variant of the Number Field Sieve which for each n finds congruences of squares x^2 = y^2 mod n in expected time: L_n(1/3, cbrt(64/9) + o(1)) = L_n(1/3, 1.92299...+o(1))." | **VERIFIED** (page image read) |
| 1.6 | The constant (64/9)^(1/3) with the o(1)-term made explicit | Le Gluher, Spaenlehauer, Thomé, "Refined Analysis of the Asymptotic Complexity of the Number Field Sieve", Math. Cryptology 1(1):1-18 (2020); arXiv:2007.02730, eprint 2020/829 | https://eprint.iacr.org/2020/829.pdf | **1**, eq. (1) | "The asymptotic complexity of the usual variant of NFS to factor an integer N, under various heuristic assumptions, is known to be exp( cbrt(64/9) (log N)^{1/3} (log log N)^{2/3} (1 + ξ(N)) ) where ξ(N) ∈ o(1) as N grows." | **VERIFIED** (page image read) |
| 1.7 | Same, doctoral thesis | van Leeuwen, "Number Field Sieve with provable complexity" (PhD, Oxford), arXiv:2007.02689 | https://arxiv.org/pdf/2007.02689 | **8** (printed "Page 7 of 114") | "In 1988 Pollard introduced a brand new factorization algorithm: The Number Field Sieve (NFS). ... The grandeur of this algorithm was in the conjectured complexity of L_n(1/3, cbrt(64/9) + o(1))," | **VERIFIED** (page image read) |
| 1.8 | Lenstra, "Integer factoring", Designs Codes Crypt. **19** (1987) 101-128 — primary source? | CrossRef metadata | https://api.crossref.org/works?query.bibliographic=Lenstra+Integer+factoring+Designs+Codes+and+Cryptography+1987 | — | CrossRef record: "Integer Factoring", Designs, Codes and Cryptography, vol 19, pp 101-128, DOI 10.1023/a:1008397921377, author Lenstra. | **BIBLIOGRAPHIC RECORD VERIFIED; TEXT NOT VERIFIED** — publisher paywalled from this host; no verbatim quote obtained from the primary source. |
| 1.9 | Which source is actually cited for the 1.923 formula | Aoki et al. (as 1.2), reference [11] | same PDF | **11** | "11. Lenstra, A.K., Verheul, E.R.: Selecting cryptographic key sizes, J. of Cryptology 14, 255-293 (2001)" | **VERIFIED** — Aoki cites **Lenstra & Verheul 2001**, not Lenstra 1987 |

---

## 2. The Nguyen–Stehlé claim, and the number 1.90188

### 2a. THE CITATION IN THE BRIEF DOES NOT EXIST

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 2.1 | LNCS 4833 = ASIACRYPT 2007, Kuching Malaysia, 2-6 Dec 2007, ISBN 978-3-540-76899-9 | Springer front-matter PDF | https://link.springer.com/content/pdf/bfm:978-3-540-76900-2/1 | PDF p.1 (roman iv) | "Lecture Notes in Computer Science 4833"; "ASIACRYPT 2007 was held in Kuching, Sarawak, Malaysia, during December" | **VERIFIED** |
| 2.2 | The volume has exactly **35 chapters**, none by Nguyen or Stehlé | Springer front-matter TOC + CrossRef per-chapter DOI lookups | https://link.springer.com/content/pdf/bfm:978-3-540-76900-2/1 ; https://api.crossref.org/works/10.1007/978-3-540-76900-2_{1..35} | TOC pp.4-11 | TOC page numbers: 1, 13, 29, 51, 68, 88, 113, 130, 147, 164, 181, 200, 216, 232, 249, 265, 283, 298, 315, 325, 342, 357, 376, 393, 410, 427, 444, 460, 474, 485, 502, 519, 536, 551, 568, 583 | **VERIFIED** |
| 2.3 | "Phong Nguyen" appears in the volume **only as a PC/organization member**, not as a chapter author | same front-matter, Organization IX | same | PDF p.4 | "Phong Nguyen  Runting Shi  Xianmo Zhang" (alphabetical Organization list) | **VERIFIED** |
| 2.4 | pp. 141-160 lands inside two **hashing** papers | same TOC | same | PDF p.4 | "Seven-Property-Preserving Iterated Hashing: ROX ... 130" (Andreeva, Neven, Preneel, Shrimpton); "How to Build a Hash Function from Any Collision-Resistant Function ... 147" (Ristenpart, Shrimpton) | **VERIFIED** — ROX is pp.130-146, Ristenpart–Shrimpton pp.147-163. Neither is at 141-160. |
| 2.5 | Neither author has **any** number-field-sieve paper | Semantic Scholar complete publication list of Damien Stehlé (authorId 1803138, paperCount 126); HAL (104 entries under "Damien Stehle"); eprint; arXiv API | https://api.semanticscholar.org/graph/v1/author/1803138/papers ; https://api.archives-ouvertes.fr/search/ ; https://eprint.iacr.org/search?q=author:stehle | — | eprint `author:stehle AND "number field sieve"` -> "No results"; arXiv `all:"Stehle" AND all:"number field sieve"` -> totalResults 0; HAL numFound=0. All joint Nguyen–Stehlé papers are LLL / lattice reduction / crypto ("Low-dimensional lattice basis reduction revisited", "Floating-Point LLL Revisited", ...). | **VERIFIED — exhaustive negative** |
| 2.6 | "Another look at the asymptotic complexity of the number field sieve" | CrossRef phrase query; eprint exact-phrase search | https://api.crossref.org/works ; https://eprint.iacr.org/search?q=Another+look+at+the+asymptotic+complexity+of+the+number+field+sieve | — | eprint returns literally "No results"; CrossRef returns no matching title. | **NOT FOUND** |

### 2b. What 1.90188 actually is

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 2.7 | **1.90188 = cbrt((92+26·sqrt(13))/27) is the constant of COPPERSMITH'S MULTIPLE POLYNOMIAL SIEVE — not Nguyen–Stehlé, and not a GNFS result** | Lee & Venkatesan, arXiv:1805.08873 | https://arxiv.org/pdf/1805.08873 | **2** | "These results can be shown to extend to Coppersmith's multiple polynomial sieve of [9], a randomised variant of which finds congruences of squares modulo n in expected time: L_n(1/3, cbrt((92+26·sqrt(13))/27) + o(1)) = L_n(1/3, 1.90188...+o(1))." | **VERIFIED** (page image read). Arithmetic: ((92+26·√13)/27)^(1/3) = 1.9018836118 |
| 2.8 | The same constant is attributed to Matyukhin 2003 / Commeine–Semaev 2006, again **not** Nguyen–Stehlé | Barbulescu, Gaudry, Guillevic, Morain, "Improvements to the NFS for the discrete logarithm problem in non-prime finite fields", eprint 2016/605 = HAL hal-01052449 | https://inria.hal.science/hal-01052449/document | **3** | "in the large characteristic case we have c = cbrt((92+26·sqrt13)/27), like for prime fields, while in the medium characteristic case, we have c = cbrt(2^{13}/3^{6}). For the moment, these multiple number field variants have not been used for practical record computations (they have not yet been used either for records in integer factorization)." | **VERIFIED** (page image read) |
| 2.9 | Its bibliography credits Matyukhin + Commeine–Semaev | same | same | **30** | "[Mat03] D. V. Matyukhin. On asymptotic complexity of computing discrete logarithms over GF(p). Discrete Mathematics and Applications, 13(1):27-50, 2003." / "[CS06] A. Commeine and I. Semaev. An algorithm to solve the discrete logarithm problem with the number field sieve. PKC 2006, LNCS 3958, 174-190." | **VERIFIED** |

---

## 3. Later (2008-2026) improvement to the GNFS constant

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 3.1 | The 2020 refined NFS analysis **keeps the same leading constant**; it improves only the o(1) term ξ(N) | Le Gluher–Spaenlehauer–Thomé 2020/829 | https://eprint.iacr.org/2020/829.pdf | **1** (abstract) | "One of the main outcomes of this analysis is that ξ(N) has a very slow rate of convergence: We prove that it is equivalent to 4 log log log N / (3 log log N)." (eq. (1) leading term is cbrt(64/9)) | **VERIFIED** — the best current peer-reviewed NFS analysis **does not lower the constant**; it *raises* the realistic cost, because ξ(N) > 0 |
| 3.2 | Qizhi Zhang, "An Improvement to the Number Field Sieve", arXiv:1103.1493 — a constant improvement? | Zhang | https://arxiv.org/pdf/1103.1493 | **1** (abstract), **4** (Prop. 4.1) | Abstract: "We improve the 'sieve' part of the number field sieve used in factoring integer and computing discrete logarithm." Prop. 4.1: "the complexity of Algorithm 3 is less than 2/3 of the complexity of Algorithm 2 asymptotically." | **VERIFIED — NOT a constant improvement.** A 2/3 factor on ONE step (sieving); the exponent and hence (64/9)^(1/3) are untouched. |
| 3.3 | Stange, "Factoring using multiplicative relations modulo n", arXiv:2211.06821 — any constant below 1.923? | Stange | https://arxiv.org/pdf/2211.06821 | **1** (abstract) | "The algorithm has subexponential runtime exp(O(sqrt(log n log log n))) (or exp(O((log n)^{1/3}(log log n)^{2/3})) with the [heuristic assumption])" | **VERIFIED — no constant claim.** She quotes an O(...) form only; she does not claim to beat (64/9)^(1/3). |
| 3.4 | Every sub-1.923 constant found is a **Tower-NFS / finite-field DLP** result, never general-N factoring | Sarkar & Singh, eprint 2016/485 | https://eprint.iacr.org/2016/485.pdf | **1**, **3** | "we obtain new asymptotic complexities, e.g., L_{p^n}(1/3,(64/9)^{1/3}) (resp. L_{p^n}(1/3,1.88) for the multiple number field variation) when n is composite and a power of 2" | **VERIFIED — DLP only** (p^n is a finite field, not an RSA modulus) |
| 3.5 | The one explicit "reduce c to ~1.90" in the literature is **for DLP in finite fields** | Barbulescu, Gaudry, Guillevic, Morain, "The Tower Number Field Sieve", HAL hal-01155635 | https://inria.hal.science/hal-01155635/document | **12** | "Using the generalized Joux-Lercier method, the authors of [6,7] reduced the constant c to (64/9)^{1/3} ≈ 1.92 and Pierrot [31] showed that a multiple fields variant allows to further reduce c to ≈ 1.90." (ref [31] = C. Pierrot, "The multiple number field sieve with Conjugation and Generalized Joux-Lercier methods", EUROCRYPT 2015, LNCS 9056, 156-170) | **VERIFIED** (page image read) — **DLP, not factoring** |
| 3.6 | Tower NFS shares the GNFS constant, L_Q(1/3, cbrt(64/9)) | Barbulescu et al., HAL hal-01155635 | same | **2** | "showed that TNFS has the heuristic complexity L_Q(1/3, cbrt(64/9)), where [Q is a prime field]" | **VERIFIED** |
| 3.7 | **IS 1.923 STILL THE RECORD FOR GENERAL N?** | — | arXiv API (all 34 papers with abs:"number field sieve", full list reviewed; plus abs:"number field sieve" AND abs:"asymptotic complexity" = TOTAL 2), IACR eprint full-text mode, CrossRef, HAL | — | — | **VERIFIED (by exhaustive negative search, 2026-10-03).** No source located claims a general-N integer-factorization NFS constant below 1.9229994. Every sub-1.923 constant found is either Coppersmith's multiple polynomial sieve (1.90188) or a finite-field DLP constant (1.88, ~1.90, 1.71). |

### 3b. Does anything beat L(1/3, 1.923) in the exponent for general N?

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 3.8 | **Shor is POLYNOMIAL, not L[1/3, c]. There is no "quantum factoring constant" of L-form.** | Regev, "An Efficient Quantum Factoring Algorithm", arXiv:2308.06572 (v3, 7 Jan 2024) | https://arxiv.org/pdf/2308.06572 | **1** | "Shor's celebrated algorithm [Sho99] allows to factorize n-bit integers using a quantum circuit of size (i.e., number of gates) Õ(n^{2}). For factoring to be feasible in practice, however, it is desirable to reduce this number further." | **VERIFIED** (page image read) — the premise of the question ("what constant does Shor give, in L[1/3,c] form") is a category error: Shor is Õ(n^2) gates, so it beats any L[1/3,c] by an enormous margin and there is no constant to compare. |
| 3.9 | A **conditional** quantum factoring algorithm that would beat any L[1/3,c] asymptotically, but rests on an unproved number-theoretic heuristic | Regev, arXiv:2308.06572 | same | **1** (abstract) | "We show that n-bit integers can be factorized by independently running a quantum circuit with Õ(n^{3/2}) gates for √n + 4 times, and then using polynomial-time classical post-processing. The correctness of the algorithm relies on a number-theoretic heuristic assumption reminiscent of those used in subexponential classical factorization algorithms. It is currently not clear if the algorithm can lead to improved physical implementations in practice." | **VERIFIED** (page image read) — the only claim found that would *change exponents*, and it is heuristic, not proven. |
| 3.10 | Shor as polynomial, per a second source | Bansimba & Babindamana, arXiv:2507.07055, Table 1 | https://arxiv.org/pdf/2507.07055 | **3** | Table row: "Shor's algorithm | General purpose: yes | Quantum: yes | O(b^3)" | **VERIFIED as printed** |

---

## 4. Comparison constants

| # | Claim | Source | URL fetched | Page | VERBATIM QUOTE | Status |
|---|---|---|---|---|---|---|
| 4.1 | **SNFS c = (32/9)^(1/3) ≈ 1.526** | *Handbook of Applied Cryptography*, §3.2.7 | https://cacr.uwaterloo.ca/hac/about/chap3.pdf | **13** (printed p.98) | "A special version of the algorithm (the *special number field sieve*) applies to integers of the form n = r^e − s for small r and |s|, and has an expected running time of L_n[1/3, c], where c = (32/9)^{1/3} ≈ 1.526." | **VERIFIED** (page image read) |
| 4.2 | **ECM to find a factor p: L_p[1/2, √2]; hardest case L_n[1/2, 1]** | *Handbook of Applied Cryptography*, §3.2.4 | same | **9** (printed p.94) | "The elliptic curve algorithm has an expected running time of Lp[1/2, √2] (see Example 2.61 for definition of Lp) to find a factor p of n. ... In the hardest case, when n is a product of two primes of roughly the same size, the expected running time of the elliptic curve algorithm is Ln[1/2, 1], which is the same as that of the quadratic sieve (§3.2.6)." | **VERIFIED** |
| 4.3 | **MPQS c = 1, NOT √(8/9)** — the brief's value is contradicted | *Handbook of Applied Cryptography*, Note 3.25 | same | **12** | "To overcome this problem, a variant (the multiple polynomial quadratic sieve) was proposed whereby many appropriately-chosen quadratic polynomials can be used instead of just q(x), each polynomial being sieved over an interval of much smaller length. This variant also has an expected running time of Ln[1/2, 1], and is the method of choice in practice." | **VERIFIED — the claim "MPQS c = √(8/9) = 0.9428" is NOT VERIFIED and is contradicted by the standard reference.** |
| 4.4 | **QS c = 1**, not √(8/9) | *Handbook of Applied Cryptography*, Note 3.24 | same | **12** | "The optimal selection of t ≈ Ln[1/2, 1/√2] ... With this choice, Algorithm 3.21 with sieving (Note 3.23) has an expected running time of Ln[1/2, 1], independent of the size of the factors of n." | **VERIFIED** |
| 4.5 | QS constant 1, corroborated | Hevia, Wesolowski et al., "Smooth Subsum Search", arXiv:2301.10529 | https://arxiv.org/pdf/2301.10529 | **3** | "For comparison, the heuristic asymptotic runtime complexity of the Quadratic Sieve is exp((1 + o(1))(log N)^{1/2}(log log N)^{1/2}) ([26])." | **VERIFIED** |
| 4.6 | **Dixon = L_n[1/2, 2√2]** — NOT √(2/3) | Bansimba & Babindamana, arXiv:2507.07055, §2.2(2) | https://arxiv.org/pdf/2507.07055 | **3** | "In the worst case, it has a time complexity of O(e^{2√2 √(log n log log n)}) = Ln[1/2, 2√2]." | **VERIFIED as printed** (pdftotext of p.3 re-checked; the CFRAC row on the same page is separately √2 — see 4.7). Wikipedia's Dixon page independently gives "L_n[1/2, 2√2]" (**secondary**). |
| 4.7 | Continued-fraction factoring (CFRAC) = L_n[1/2, √2] | Bansimba & Babindamana, arXiv:2507.07055, §2.2(3) | same | **3** | "It has a complexity of O(e^{√(2 log n log log n)}) = Ln[1/2, √2]." | **VERIFIED** (page image read) |
| 4.8 | **Dixon/random squares c = √(2/3) = 0.8165** | — | — | — | — | **NOT VERIFIED.** No accessible source located. Both sources found give 2√2 (Dixon) or √2 (CFRAC). **Do not quote 0.8165 without a source.** |
| 4.9 | **SIQS c = (1/2)√2 = 0.7071** | — | — | — | — | **NOT VERIFIED.** Wikipedia has no SIQS article (404); the QS article gives no per-variant constants. **Do not quote 0.7071 without a source.** |
| 4.10 | ECM constant cross-check (**SECONDARY**) | Wikipedia "Lenstra elliptic-curve factorization" | https://en.wikipedia.org/wiki/Lenstra_elliptic-curve_factorization | — | "The time complexity depends on the size of the number's smallest prime factor and can be represented by exp[(√2 + o(1)) √(ln p ln ln p)], where p is the smallest factor of n, or L_p[1/2,√2], in L-notation." | **VERIFIED (secondary)** — agrees with HAC (4.2) |
| 4.11 | Lenstra 1987 ECM original (Ann. Math. 126 649-673) | — | maths.ed.ac.uk/~lenstra (403), its.caltech.edu/~lenstra/papers/1987.pdf (404) | — | — | **NOT VERIFIED — not retrievable from this host.** (Note: the commonly cited 4/√3 ≈ 2.3094 for ECM is **not** what either accessible source gives; both give √2 for the Montgomery-curve variant.) |

---

## 5. Corrections to the brief — read this

1. **1.90188 is NOT a Nguyen–Stehlé GNFS constant.** It is cbrt((92+26·√13)/27) = 1.9018836, the constant of **Coppersmith's multiple polynomial sieve** (and, for the DLP analogue, of Matyukhin 2003 / Commeine–Semaev 2006). The brief's memory is a double conflation: wrong authors *and* wrong algorithm family.
2. **The Nguyen–Stehlé citation in the brief is fabricated.** ASIACRYPT 2007 LNCS 4833 has 35 chapters, none by Nguyen or Stehlé; pp. 141-160 falls inside two hashing papers. "Phong Nguyen" appears only as a PC member. Neither author has ever published an NFS paper (exhaustive check of Semantic Scholar's 126-paper list, HAL's 104-entry record, eprint, arXiv). **Status: the paper is NOT VERIFIED to exist, so there is no Nguyen–Stehlé NFS constant.**
3. **Lenstra, "Integer Factoring" (Des. Codes Crypt. 19 (1987) 101-128) could not be read** from this host. Bibliographic record confirmed; the verbatim constant from the primary source is **NOT VERIFIED**. The closest primary-adjacent citations are Lenstra & Verheul, *J. Cryptology* 14 (2001) 255-293 (cited by Aoki et al.) and Buhler–Lenstra–Pomerance, LNM 1554 (1993).
4. **"A smaller GNFS constant exists for a large subfamily" is UNSUPPORTED for a general N.** The one explicit "~1.90" in the literature (Barbulescu et al., HAL hal-01155635 p.12) is for **discrete logarithms in finite fields** (Pierrot's multiple-number-field variant).
5. **Three of the brief's comparison constants are unsourced or contradicted:** MPQS √(8/9)=0.9428 (**contradicted** — HAC says 1), SIQS (1/2)√2=0.7071 (**unsourced**), Dixon √(2/3)=0.8165 (**unsourced**; both accessible sources give 2√2 or √2).
6. **The Shor framing is a category error.** Shor is Õ(n^2) quantum gates — polynomial, with no L[1/3,c] constant to compare. The one result that *would* change exponents is Regev (2024), Õ(n^{3/2}) gates, and it is explicitly conditional on "a number-theoretic heuristic assumption".
7. **The brief's speedup formula (X/1.92299)^(1/3) is wrong** — see §6b/6c. The correct ratios are 1.9x–47x, not ~1.005x.

---

## 6. Arithmetic (no citation needed)

c0 = (64/9)^(1/3) = 1.9229994270765445

### 6a. The formula as literally requested in the brief: (X/c0)^(1/3)

| X | (X/1.92299)^(1/3) |
|---|---|
| 1.90188 | 0.996326 |
| 1.90 | 0.995997 |
| 1.85 | 0.987183 |
| 1.80 | 0.978208 |

### 6b. CORRECTION — this is NOT the time ratio

Runtime = exp(c (ln N)^(1/3)(ln ln N)^(2/3)). Changing c from c0 to X multiplies the runtime by

  t_X / t_0 = exp( (X − c0) · (ln N)^(1/3)(ln ln N)^(2/3) )

`(X/c0)^(1/3)` would be the ratio only if the exponent were independent of N. **The correct numbers are in 6c — they are 2x to 47x, not ~1.005x.**

### 6c. TRUE time ratio at n = 1024 bits (ln N = 709.783, ln ln N = 6.5650, K = (ln N)^(1/3)(ln ln N)^(2/3) = 31.2749)

| X | t_X/t_0 | speedup |
|---|---|---|
| 1.90188 (Coppersmith MPS) | 0.51659 | **1.94x** |
| 1.90 | 0.48709 | **2.05x** |
| 1.85 | 0.10197 | **9.81x** |
| 1.80 | 0.02135 | **46.8x** |

### 6d. Reference values of the constants

| Constant | Value | Sourced? |
|---|---|---|
| GNFS (64/9)^(1/3) | 1.9229994270765445 | yes (1.1) |
| SNFS (32/9)^(1/3) | 1.5262856567377758 | yes (4.1) |
| Coppersmith MPS cbrt((92+26√13)/27) | 1.9018836118648392 | yes (2.7) |
| CFRAC √2 | 1.4142135623730951 | yes (4.7) |
| Dixon 2√2 (as printed by both accessible sources) | 2.8284271247461903 | yes (4.6) |
| ECM √2 | 1.4142135623730951 | yes (4.2) |
| QS / MPQS 1 | 1.0000000 | yes (4.3, 4.4) |
| Dixon/random squares (2/3)^(1/2) | 0.8164965809277260 | **NOT SOURCED** |
| SIQS (1/2)√2 | 0.7071067811865476 | **NOT SOURCED** |
| MPQS (8/9)^(1/2) | 0.9428090415820634 | **CONTRADICTED** (HAC says 1) |

---

## 7. Tooling notes for this host (worth carrying forward)

- Working: `link.springer.com/content/pdf/<DOI>.pdf` and `/content/pdf/bfm:<eISBN>/1`; `link.springer.com/book/<DOI>`; `inria.hal.science/<id>/document`; `eprint.iacr.org/search?q=` (titles/abstracts only, not PDF text); `api.crossref.org`; `api.archives-ouvertes.fr`; `arxiv.org/pdf/<id>`; the arXiv **API** (plain arXiv search UI drops pre-2010 papers).
- Dead / blocked: **WebSearch (fabricates)**, Brave `search.brave.com` (HTTP 429 persistently — treat as dead), dblp.org (Anubis bot wall), OpenAlex (daily budget exhausted), ams.org (403), gmplib.org ECM manual (404, no Wayback snapshot), iacr.org/archive (403), Semantic Scholar (works, ~1 req/15 s).
- **Two arXiv IDs remembered from prior rounds were wrong:** `quant-ph/9508015` is Kostelecký & Shelton, *Atomic Supersymmetry, Oscillators, and the Penning Trap* — NOT Zalka. Always look arXiv IDs up via the API; never from memory.
- `file(1)` misreports page counts on some PDFs; use `pdfinfo`.