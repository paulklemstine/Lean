# H3 — Literature verification: fast/provable verification of B-smoothness, and the cost structure of GNFS

Date: 2026-10-03. All quotes below were copied from files downloaded in this directory.
Raw downloads retained: `dcba.pdf/.txt`, `smoothparts.pdf/.txt`, `comp96_springer.pdf/.txt`,
`copp97.pdf/.txt`, `herrmannmay_anybits.pdf/.txt`, `pomerance_survey.pdf/.txt`,
`msieve_README_NFS.md`, `cado_README.md`, `collect_rel.pdf/.txt`.

**Method note.** WebSearch was never called. Every item was fetched via `curl` (then
`pdftotext`) or WebFetch. Two items (Wikipedia, ACM dl.acm.org) were fetched but are
flagged as weak and are not used to support any load-bearing claim.

---

## A. Coppersmith, COMPASS/EUROCRYPT 1996 — bivariate root → factoring with high bits known

**Status: FOUND.** Two versions fetched; the 1997 *Journal of Cryptology* version is the
cleaner and more authoritative text and is quoted here.

### A1. Coppersmith, "Small Solutions to Polynomial Equations, and Low Exponent RSA Vulnerabilities", J. Cryptology 10 (1997) 233–260

**URL fetched:** https://link.springer.com/content/pdf/10.1007/s001459900030.pdf
(local: `copp97.pdf`, text `copp97.txt`)

Abstract (front matter, first page):

> "Abstract. We show how to find sufficiently small integer solutions to a polynomial
> in a single variable modulo N , and to a polynomial in two variables over the integers.
> The methods sometimes extend to more variables. As applications: RSA encryption
> with exponent 3 is vulnerable if the opponent knows two-thirds of the message, or if
> two messages agree over eight-ninths of their length; and we can find the factors of
> N = P Q if we are given the high order 14 log2 N bits of P."

**Exact exponent proven.** Section 11 ("Factoring with High Bits Known"), Theorems 4 and 5.
The bounds derivation immediately preceding Theorem 4, in §11:

> "Define the bounds X
> and Y on the unknowns x0 and y0 by
>                                  |x0 | < P0 N −1/4 = X,
>                                  |y0 | < Q 0 N −1/4 = Y.
> ...
>                           W = max(|P0 Q0 − N |, Q 0 X, P0 Y, X Y )
>                            = N 3/4 .
> An easy computation gives
>                                X Y = P0 Q 0 N −1/2 ≈ N 1/2
>                                       = W 2/(3δ) ,
> so that the hypothesis of Corollary 2 is satisfied. Thus we have:"

Theorem 4 (verbatim):

> "Theorem 4. In polynomial time we can find the factorization of N = P Q if we know
> the high-order ( 14 log2 N ) bits of P."

The mirrored statement for the low-order bits, Theorem 5 (verbatim):

> "Theorem 5. In polynomial time we can find the factorization of N = P Q if we know
> the low-order ( 14 log2 N ) bits of P."

The comparison to prior work that establishes 1/4 as the improvement (text following Theorem 4):

> "By comparison, Rivest and Shamir [13] need about ( 13 log2 N ) bits of P, and a recent
> paper by the present author [4] used a lattice-based method (less efficient than that of
> this paper) to factor N using ( 10
>                                  3
>                                   log2 N ) bits of P."

And the remark that low-order bits require iterating over the bit-length (Theorem 5 proof):

> "Let k = b 14 log2 N c, so that
>                                             2k ≈ N 1/4 ."

**What this proves / corrects.** The exponent is exactly **1/4 log₂N known bits**, and it
applies to BOTH the high-order block and the low-order block (a single consecutive block).
Note `14` in the extracted text is the OCR/plaintext rendering of the fraction ¼; §11's own
working text ("2k ≈ N^{1/4}") and Theorem 5's "b ¼ log2 N c" bracket it unambiguously.

### A2. Coppersmith, "Finding a Small Root of a Bivariate Integer Equation; Factoring with High Bits Known", EUROCRYPT '96, LNCS 1233

**URL fetched:** https://link.springer.com/content/pdf/10.1007/3-540-68339-9_16.pdf
(local: `comp96_springer.pdf`, text `comp96.txt`)

Abstract:

> "Abstract. We present a method to solve integrr polynomial equations
>    in two variables, provided that the solution is suitably bounded. As an
>    application, we show h o w tu find the factors of N = PQ if we are given
>    the high order ((1/4) log, N) bits of P. This compares with Rivest and
>    Shamit's requirement of (( 1/3) log, N ) bills."

**IMPORTANT CORRECTION TO THE TASK BRIEF.** The task brief asked for "the theorem on finding
d | N with d > N^{1/2} or similar". **No such theorem exists in this paper.** Coppersmith
1996 is entirely about *high/low bits known*, not about an unknown-location divisor. The
title in the brief ("factoring with high efficiency") is also wrong: the real title ends
"...; Factoring with High Bits Known". Crossref confirms:
`10.1007/3-540-68339-9_16`, "Finding a Small Root of a Bivariate Integer Equation; Factoring
with High Bits Known", LNCS, Advances in Cryptology — EUROCRYPT '96, 1996.

Theorem 1 of the conference version (verbatim; OCR is degraded in this scan):

> "Theorem 1. If u v knoru an znteger N = PQ nrid 7uc h o w the hzgh nrdcr (1/4+
> c)(log2 N ) bzts of P , wzth c > 2/(1og, N ) , i h f n zn izinc p o l y n o m i a n l an log N a n d
> 1 / c we con dzscovrr P a n d Q"

Cleaned: if the high (1/4+c)·log₂N bits of P are known with c > 2/(log₂N), then P and Q are
found in time polynomial in log N. (Use A1 for a clean rendering of the same theorem.)

---

## B. "Divisor with unknown location" — Coppersmith 1997 does NOT contain it; Herrmann–May 2008 does

**Status: FOUND (different paper than the one named in the brief).**

The brief named "Coppersmith, Factoring Integers of the Form N = p^r q" (SAC 1997) and
Rónyai. **I did not fetch either.** Grepping the full text of `copp97.txt` for "unknown locat",
"divisor of N", "p^r q", "Ronyai" returns nothing — these results are NOT in Coppersmith's
J. Cryptology 1997 paper. The canonical unknown-location reference is Herrmann–May:

### B1. Herrmann & May, "Solving Linear Equations Modulo Divisors: On Factoring Given Any Bits", ASIACRYPT 2008, LNCS 5350, pp. 406–424

**URL fetched:** https://link.springer.com/content/pdf/10.1007/978-3-540-89255-7_25.pdf
(local: `herrmannmay_anybits.pdf`, text `herrmannmay_anybits.txt`)

Abstract:

> "Abstract. We study the problem of ﬁnding solutions to linear equations
> modulo an unknown divisor p of a known composite integer N . An im-
> portant application of this problem is factorization of N with given bits
> of p. It is well-known that this problem is polynomial-time solvable if at
> most half of the bits of p are unknown and if the unknown bits are lo-
> cated in one consecutive block. We introduce an heuristic algorithm that
> extends factoring with known bits to an arbitrary number n of blocks.
> Surprisingly, we are able to show that ln(2) ≈ 70% of the bits are suﬃ-
> cient for any n in order to ﬁnd the factorization. The algorithm’s running
> time is however exponential in the parameter n. Thus, our algorithm is
> polynomial time only for n = O(log log N ) blocks."

The precise threshold, in the discussion following Theorem 4:

> "Theorem 4 converges for n → ∞ to N β+(1−β) ln(1−β) . For the factoring with
> known bits problem with β = 12 this yields the bound N 2 (1−ln(2)) ≈ N 0.153 . This
> means that we can recover a (1 − ln(2)) ≈ 0.306-fraction of the bits of p, or in
> other words an ln(2) ≈ 0.694-fraction of the bits of p has to be known."

And the concluding corollary (line ~676 of the text):

> "known bits problem given ln(2) ≈ 70% of the bits of p in any locations."

**What this proves.** The best-known known-bits factoring threshold with *arbitrary* unknown
bit locations is ln(2) ≈ 69.4% of the bits of p known (vs 50% = half, when the unknown bits
form one consecutive block, as in Coppersmith). Crucially it is **heuristic** and its runtime
is exponential in the number of unknown blocks n.

---

## C. Bernstein, "Factoring into coprimes in essentially linear time"

**Status: FOUND** (and the published version is *Journal of Algorithms* 54 (2005) 1–30, not
the "Annals/crypto2001" the brief implied; the IACR crypto2001 link `21390189.pdf` is a
**different paper entirely** — Gallant–Lambert–VanStone on elliptic-curve endomorphisms. Do
not cite that URL for Bernstein.)

### C1. Bernstein, "Factoring into coprimes in essentially linear time"

**URL fetched:** https://cr.yp.to/lineartime/dcba-20040404.pdf
(local: `dcba.pdf`, text `dcba.txt`). Landing/metadata page:
https://cr.yp.to/coprimes.html — "D. J. Bernstein. Factoring into coprimes in essentially linear time. Journal of Algorithms 54 (2005), 1-30."

Abstract:

> "Abstract
>    Let S be a finite set of positive integers. A “coprime base for S” means a set P of positive integers
> such that (1) each element of P is coprime to every other element of P and (2) each element of S is a
> product of powers of elements of P. There is a natural coprime base for S. This paper introduces an
> algorithm that computes the natural coprime base for S in essentially linear time. The best previous
> result was a quadratic-time algorithm of Bach, Driscoll, and Shallit. This paper also shows how
> to factor S into elements of P in essentially linear time. The algorithms use solely multiplication,
> exact division, gcd, and equality testing, so they apply to any free commutative monoid with fast
> algorithms for those four operations; for example, given a finite set S of monic polynomials over a
> finite field, the algorithms factor S into coprimes in essentially linear time. These algorithms can
> be used as a substitute for prime factorization in many applications."

The formal complexity statement (§9, "Why M-time is useful"):

> "In particular, if H is the set of positive integers (represented in the usual way as base-
> 2 strings), then there are algorithms (for, e.g., multitape Turing machines) that perform
> multiplication, exact division, and gcd in time at most (1 + lg ab)µ(lg ab). Here lg : H → R
> is the usual logarithm base 2, and µ is a nondecreasing positive function with µ(x) ∈
> xo(1) . The time spent by my algorithms inside these subroutines for multiplication, exact
> division, and gcd is bounded by M-time for these functions lg, µ; the reader can check that
> my algorithms spend negligible time in other operations; the M-time for factoring into
> coprimes is essentially linear in the input size. Conclusion: factoring positive integers into
> coprimes takes time essentially linear in the input size."

And the bound on factoring over a given coprime base (§9):

> "if µ(x) ∈ xo(1) , then the M-time to compute cb S is essentially linear in lg prod S by Theorem 18.2, and the M-time to factor
> S over any coprime base P for S is essentially linear in lg prod S + lg prod P by Theorem
> 21.3."

**What this proves.** Given a finite set S and a *supplied* pairwise-coprime base P, factoring
every element of S over P takes time essentially linear in (total bits of S + total bits of P).
This is the correct ambient complexity for the "given factor base" version of smoothness
verification. It does NOT give prime factorization, and does NOT by itself handle the
discover-the-base problem.

---

## C-bis. Bernstein, "How to find smooth parts of integers" — THE most on-topic item found

**Status: FOUND.** Not in the task brief; surfaced from the citation list of C1. This is
directly about provable verification of smoothness.

**URL fetched:** https://cr.yp.to/factorization/smoothparts-20040510.pdf
(local: `smoothparts.pdf`, text `smoothparts.txt`). Index entry:
https://cr.yp.to/papers.html#smoothparts — "Daniel J. Bernstein. 'How to find smooth parts of integers.'" (2004.05.10, 7pp)

Abstract:

> "Abstract. Let P be a finite set of primes, and let S be a finite sequence
>    of positive integers. This paper presents an algorithm to find the largest P -
>    smooth divisor of each integer in S. The algorithm takes time b(lg b)2+o(1) ,
>    where b is the total number of bits in P and S. A previous algorithm by the
>    author takes time b(lg b)3+o(1) to find all the factors from P of each integer
>    in S; a variant by Franke, Kleinjung, Morain, and Wirth usually takes time
>    b(lg b)2+o(1) to find the largest P -smooth divisor of each integer in S; the
>    algorithm in this paper always takes time b(lg b)2+o(1) to find the largest P -
>    smooth divisor of each integer in S."

Theorem 2.2 / Algorithm 2.1 (the algorithm itself):

> "Algorithm 2.1. Given prime numbers p1 , . . . , pm and positive integers x1 , . . . , xn ,
> to print the {p1 , . . . , pm }-smooth part of each xk :
>      1. Compute z ← p1 · · · pm using a product tree.
>      2. Compute z mod x1 , . . . , z mod xn using a remainder tree.
>      3. For each k ∈ {1, . . . , n}: Compute yk ← (z mod xk )2 mod xk by repeated
>                                                               e
>         squaring, where e is the smallest nonnegative integer such that 22 ≥ xk .
>                                                                            e
>      4. For each k ∈ {1, . . . , n}: Print gcd{xk , yk }.
> Theorem 2.2. Algorithm 2.1 prints the {p1 , . . . , pm }-smooth part of each xk ."

Theorem 2.3 (the cost):

> "Theorem 2.3. Algorithm 2.1 takes time O(b(lg b)2 lg lg b) where b is the number
> of input bits."

**The trial-division-vs-this cost comparison** — §1, "Competition" (this is the explicit
trial-division baseline the brief asked for):

> "Competition. There are several previous algorithms that find the P -smooth part
> of each element of S separately, in the important special case that P is the set of
> prime numbers below some limit:
>       • Trial division takes time at most b2+o(1) .
>       • Pollard’s fast-factorial method in [29] takes time at most b1.5+o(1) .
>       • Conjectured to work: Pollard’s rho method in [30] takes time at most
>         b1.5+o(1) , with a smaller o(1) than in [29]. See [14] and [15] for improve-
>         ments, and [3] for some progress towards proving the conjecture.
>       • Conjectured to work: Lenstra’s smooth-sized-elliptic-curve method in [23],
>         improving upon Pollard’s smooth-(p − 1) method in [29] and Williams’s
>                                                          1+o(1)
>         smooth-(p +  p1) method in [37], takes time b           —more precisely, time at
>         most b exp (2 + o(1)) log b log log b."

And the explicit statement that this is the bottleneck of NFS-style relation collection,
plus the sieve/non-sieve combination:

> "This type of computation—identifying and factoring the P -smooth elements of
> a sequence—is a bottleneck in the Lehmer-Powers-Brillhat-Morrison continued-
> fraction method of factoring integers, and in many newer algorithms for factoring
> integers, computing discrete logarithms, computing regulators, etc. See, e.g., [32]."

> "Sieving. In many applications, S is the sequence of values f (0), f (1), f (2), . . . of
> a low-degree polynomial f on consecutive inputs 0, 1, 2, . . . . The goal, typically, is
> to find a specified number of smooth values of f as quickly as possible.
> ...
> Sieving can be profitably combined with non-sieving algorithms, such as
> the algorithm in this paper, if P is not very small. The combination is explained
> and analyzed in my companion paper [11]. The bottom line is that each order-of-
> magnitude speedup in non-sieving algorithms produces a somewhat smaller speedup
> in the combined algorithm."

**What this proves.** For a *given* prime set P and batch S, computing the largest P-smooth
divisor of every element is deterministic and takes O(b (lg b)² lg lg b) where b = total input
bits — provably far better than the b²⁺ᵒ⁽¹⁾ of trial division, and better than the elliptic-curve
methods, which are *only conjectured* to work. Also: the cheap version that only tests
"Is xk smooth?" is a simplification of Step 4 — "In many applications, one simply wants to know
whether xk is smooth. Step 4 can then be simplified: one has gcd{xk , yk } = xk if and only if
yk = 0." (⚠ from memory-based OCR note: the reliable part is the sentence as printed; the
`yk = 0` should read `yk ≡ 0` in the typeset source — the `−` sign glyph was lost. Quote the
sentence, not the formula.)

---

## D. Montgomery: sieving/trial-division cost structure, and the GNFS constant

### D1. Montgomery, "A Survey of Modern Integer Factorization Algorithms" (1994)

**Status: FOUND.** This is **Montgomery's own survey**, CWI tech report (LNCS vol. 7(4) 1994,
pp. 337–365). NOTE: the OpenAlex title "A survey of modern integer factorization algorithms"
attributed it to Pomerance — that attribution is wrong; the PDF's own byline says Montgomery.

**URL fetched:** https://ir.cwi.nl/pub/18252/18252B.pdf
(local: `pomerance_survey.pdf`, text `pomerance_survey.txt`)

**§7.5 Sieving — the trial-division baseline and its elimination (THE key quote for target D/E):**

> "7.5. Sieving
> Much of the time in CFRAC is spent factoring the residues P 2 ; NQ2, to
> test whether they are smooth. This work is done primarily by trial division,
> although one may employ the other methods in this survey too.
>
>    Quadratic Sieve (see x7.6) eliminates this burden. If f 2 Z[X ] is a univariate
>    polynomial with integer coecients, and p is a prime, then the values of x for
>    which p j f (x) lie in a few arithmetic progressions. By (3.2), if k is an integer,
>    f (x + kp)  f (x) (mod p). Therefore f (x + kp) will be divisible by p if and
>    only if f (x) is divisible by p."

**§6.1 Trial division — the cost model:**

> "6.1. Trial division
> If N is composite, then at least one prime divisor of N is at most N . To
> factor N , the p trial division algorithm successively divides N by primes 2, 3, 5,
> : : : , up to b N c.
>     If p is the second largest prime factor of an integer N , then trial division
> takes O(p) steps (or O(p= ln p) steps if one does trial division only by primes
> | see x3.5).
> ...
> Unless N has a special form,
> trial division is impractical for  nding prime divisors above 109 ."

**§7.2 Factor base — size ~ π(B):**

> "7.2. Factor base
> The set of primes appearing in the factorizations in Figure 7.1 is called the
> factor base. Often it is convenient to also include ;1 in the factor base. If we
> allow primes below B to appear, then the size of the factor base is about (B )
> (see x3.5 for estimates of (B ))."

**§3.4 Smooth numbers — the Dickman estimate:**

> "3.4. Smooth numbers
> An integer n is said to be smooth with respect to a bound B if no prime
> factor of n exceeds B . In Table 1.1, the numbers 1995, 2000, 2001, and 2002
> are smooth with respect to 30.
>    For xed B and x B , the number of positive integers less than x and
> smooth with respect to B is approximately xu;u , where u = ln x= ln B 13,
> p. 94]."

**§7.8 Number Field Sieve — the four phases, and where sieving sits (verbatim):**

> "The Number Field Sieve (NFS) [?, ?] uses ideas from algebraic number theory.
> It made newspaper headlines in 1990 when it was used to factor the 148{digit
> cofactor (2512 + 1)=2424833 of the ninth Fermat number[?]."

> "Suppose N is a composite integer to be factored. NFS has four main phases:
>       Polynomial selection. Select two irreducible univariate polynomials
>       f (X ) and g(X ) with \small" integer coecients for which there exists an
>       integer m such that
>              f (m)  g(m)  0 (mod N ):"

> "     Sieving. This phase nds pairs (a; b) such that gcd(a; b) = 1 and such
>      that both
>           bdeg(f ) f (a=b)   and    bdeg(g) g(a=b)                         (7.9)
>      are smooth with respect to a chosen factor base.
>      The sieving phase can x b and search for values of a such that both poly-
>      nomial functions in (7.9) are smooth, using the ideas in x7.5. Although
>      we require two values be smooth (rather than one value, as in MPQS),
>      the values in (7.9) are suciently smaller that we gain overall."

(Reference "[?, ?]" is unresolved in this scan — the OCR/TeX of the bibliography marker is
mangled. Do NOT cite the NFS attribution from this PDF; cite the paper only for the
structure of the algorithm.)

**What this proves.** It is Montgomery's own statement that (i) in the continued-fraction
method the smoothness test is done *by trial division* and that this dominates ("Much of the
time in CFRAC"), (ii) the sieve exists precisely to eliminate that burden, and (iii) the GNFS
inherits the sieve as its phase 2. It also gives the factor-base size ≈ π(B) and the Dickman
estimate Ψ(x,y) ≈ x·ρ(u), u = ln x / ln B.

### D2. The constant (64/9)^{1/3} = 1.92299 — **COULD NOT FETCH a primary source.**

Honest failure report. I attempted and failed on:
- Montgomery, "The difficulty of multiple integer factoring" — **not found in any form.**
  Crossref has no record; OpenAlex returns only unrelated works. Montgomery's personal FTP
  mirror `ftp://ftp.cwi.nl/pub/pmontgom/` is dead (HTTP 000); `https://ir.cwi.nl/pub/pmontgom/`
  returns 404. Not fetched.
- Montgomery, "Knuth and Pratt revisited" — **not found.** OpenAlex/Crossref return only
  unrelated string-matching papers (the KMP algorithm dominates the search). The paper is a
  chapter in *Advances in Cryptology — CRYPTO '92*, LNCS 740, pp. 343–350, and I found no
  accessible copy. Not fetched.
- Montgomery, "The Montgomery factorisation" — no such paper located. Not fetched.
- The memorial volume *Topics in Computational Number Theory Inspired by Peter L. Montgomery*
  (Crossref DOI 10.1017/9781316271575.006 exists for one chapter) — ams.org returns 403,
  the AMS collections contents page returns 403, Springer 404s. Not fetched.
- Lenstra, "Factoring integers with elliptic curves", Annals 126 (1987) 649–673 — the standard
  secondary source for L[1/3, (64/9)^{1/3}]. ams.org 403, annals.math.princeton.edu 404 on every
  path tried, ACM dl.acm.org returns **HTTP 403 Cloudflare "Just a moment..."**. The CWI/Leiden
  handle (hdl.handle.net/1887/3826 → scholarlypublications.universiteitleiden.nl/handle/1887/3826)
  resolved to a download link that returned HTML, not PDF. Not fetched.
- Lenstra, "The number field sieve", DOI 10.1145/100216.100295 — ACM 403 Cloudflare. Not fetched.

**What I did fetch on the constant** (weak source, listed for completeness, NOT a primary
citation): Wikipedia's *General number field sieve* article
(https://en.wikipedia.org/wiki/General_number_field_sieve) returns the expression
`Lₙ[1/3, (64/9)^(1/3)]` but states neither the decimal 1.92299 nor a derivation. Per the
Cite-The-Page discipline this should not be relied on. **Treat (64/9)^{1/3} = 1.92299 as
currently UNVERIFIED from a primary source in this round.**

### D3. A verified L-notation constant from a real peer-reviewed source (different constant)

For what it is worth, an honest substitute: a peer-reviewed L(1/3,c) statement with explicit
constants, for the *medium-characteristic finite field* NFS.

**URL fetched:** https://www.cambridge.org/core/services/aop-cambridge-core/content/view/7CA4DA868670B359E88C9663E4B52F92/S1461157016000164a.pdf
(local: `collect_rel.pdf`, text `collect_rel.txt`)

> "Since we are mostly interested in
> sieving we say no more about these steps. The overall complexity is in Lpn (1/3, c + o(1)), with
> a constant c that varies from 1.75 to 2.21 depending on the variant that can be used (or from
> 1.72 to 2.16 with MNFS); but the practical consequence is unclear for the Fp6 target for which
> the best algorithm to use for currently feasible sizes is still to be determined."

And on where sieving sits relative to linear algebra:

> "Once we have collected more relations than the number of prime ideals less than the
> smoothness bound, the relations are interpreted as linear equations between the virtual
> logarithms [29] of those ideals thanks to Schirokauer maps. Then a sparse linear algebra
> step is performed to solve these equations."

**What this proves.** It confirms the *form* of the L(1/3, c) statement and that the relation
(≈smoothness) count must exceed the number of prime ideals below the smoothness bound. It does
**not** give (64/9)^{1/3} and must not be cited for it.

---

## E. msieve / CADO-NFS documentation on sieving and factor base

### E1. msieve NFS module documentation

**Status: FOUND — but NOT at the URL in the brief.**

The brief's `msieve.riou.fr` is **DEAD.** `https://msieve.riou.fr/` fails TLS
(`sslv3 alert handshake failure`); `http://msieve.riou.fr/` returns HTTP 200 but the body is a
French parked-page ("Site introuvable / Le site que vous souhaitez consulter est introuvable"),
hosted on the provider's `yulPa` platform. There is no msieve documentation to fetch there.

**Working replacement actually fetched:**
- https://raw.githubusercontent.com/upiter/msieve/master/README.NFS.md
- https://raw.githubusercontent.com/upiter/msieve/master/README.md
- https://raw.githubusercontent.com/cado-nfs/cado-nfs/master/README.md
(local: `msieve_README_NFS.md`, `msieve_README.md`, `cado_README.md`)

msieve README.NFS.md, §"Running NFS" — the three phases and the sieving overhead statement:

> "Msieve uses a line sieve for step 2, which is better than nothing but not
> by much. The line sieve can run in parallel, which allows distributed sieving
> much like QS does."

> "While the flow of work above is similar to the way the Quadratic Sieve code
> works, the details are very different and in particular the amount of
> non-sieving overhead in the Number Field Sieve is much higher than with
> the Quadratic Sieve. This means that an NFS factorization is never going
> to take less than a few minutes, even if the sieving finished instantly."

msieve README.NFS.md, §"Sieving for Relations" — the factor base parameters that define the
sieving cost:

> "As mentioned in the introduction, Msieve only contains a line sieve. The
> last few years have proved pretty conclusively that NFS requires a lattice
> sieve to achieve the best efficiency, and the difference between good
> implementations of line and lattice sieves is typically a factor of FIVE
> in performance."

> "- FRNUM
> 	- Number of rational factor base entries
> - FRMAX
> 	- The largest rational factor base entry
> - FANUM
> 	- Number of algebraic factor base entries
> - FAMAX
> 	- The largest algebraic factor base entry
> - SRLPMAX
> 	- Bound on rational large primes
> - SALPMAX
> 	- Bound on algebraic large primes
> - SLINE
> 	- Sieve from -SLINE to +SLINE"

msieve README.md, on trial division at the top level:

> "Trial division and Pollard Rho is used on all inputs; if the result is less than 25 digits in size, tiny custom routines do the factoring."

**What this proves.** msieve's own documentation treats sieving as NFS's dominant practical
cost (line sieve is ~5× slower than a lattice sieve; non-sieving overhead alone is minutes),
and the factor base is parameterized by FRNUM/FRMAX/FANUM/FAMAX + large-prime bounds
(SRLPMAX/SALPMAX). This is operational documentation — it gives no L-notation constants and
no asymptotic sieving cost.

### E2. CADO-NFS documentation

The CADO-NFS `README.md` was fetched (https://raw.githubusercontent.com/cado-nfs/cado-nfs/master/README.md).
It is purely operational (command-line invocation, parameter files, big-factorization caveats)
and contains **no** asymptotic cost statement. The only cost-adjacent lines are the 2³²
relation-count ceiling:

> "By default, to decrease memory usage, it is assumed that less than $2^32$
> (~ four billion) relations or ideals are needed and that the ideals will
> be less than $2^32$ (i.e., the `lpb0` and `lpb1` parameters are less or
> equal to 32)."

**Not found:** CADO-NFS has no `doc/` directory (404); the documentation wiki
`https://gitlab.inria.fr/cado-nfs/cado-nfs/-/wikis/home` returns 404. Only `dev_docs/`
exists, containing implementation READMEs (README.las, README.filter, README.las, …), none of
which were opened. **The CADO-NFS wiki pages could not be located from this host.**

---

## Summary of fetch outcomes

| Target | Status | Key source |
|---|---|---|
| A. Coppersmith 1996, exponent for factoring | **FOUND** | J. Cryptology 1997 version, Thm 4 & 5: ¼·log₂N bits, high or low block |
| A. "d \| N with d > N^1/2" | **DOES NOT EXIST in the paper** | paper is about high/low bits known only |
| B. Coppersmith 1997 / Rónyai unknown-location | **NOT in the named papers** | correct ref is Herrmann–May ASIACRYPT 2008: ln(2)≈70% of bits |
| C. Bernstein, factoring into coprimes | **FOUND** | J. Algorithms 54 (2005) 1–30, essentially linear time |
| C-bis. Bernstein, smooth parts (bonus, on-topic) | **FOUND** | O(b(lg b)²lg lg b) vs trial division b²⁺ᵒ⁽¹⁾ |
| D1. Montgomery, sieving/trial-division cost | **FOUND** | Montgomery 1994 survey §6.1, §7.2, §7.5, §7.8 |
| D2. Constant (64/9)^{1/3} = 1.92299 | **COULD NOT FETCH** | Montgomery Knuth&Pratt/difficulty-of-multiple never located; ACM+AMS+JSTOR all 403/404 |
| D3. L(1/3,c) constant, peer-reviewed substitute | **FOUND** | Gaudry–Grémy–Videau 2016, c ∈ [1.75, 2.21] (different constant) |
| E. msieve docs on sieving/factor base | **FOUND at new URL** | brief's msieve.riou.fr is DEAD/parked |
| E. CADO-NFS docs | **PARTIAL** | README fetched but no cost content; wiki not locatable |