# FACT r114: GIFP is not a factoring method — the campaign's only live positive is a two-modulus weak-keygen attack on *planted* instances

**Status: RETRACTION of the GIFP line (rounds 110–113). No new attack is claimed.**

---

## 1. The claim

Between rounds 110 and 113 this campaign treated **GIFP** as a novel factoring method
whose scaling law toward RSA-2048 was the principal open question. It recorded one
live positive:

> GIFP recovers `p₂` at n=800 in 3/3 while PARI `factor(N)` on the same instance ran
> >4 minutes without success. (r112)

and one open obstacle:

> the α ≥ 0.15 GIFP wall (r111c)

**Both are about an attack on a key generation that the experiment itself builds, not
about integer factoring.** More precisely, our instances hand the attacker the very
information the source paper says must be *recovered*.

---

## 2. What GIFP actually is

GIFP is the **Generalized *Implicit* Factorization Problem**, from

- Feng, Nadi, Pietrzak, *Solving the Generalized Implicit Factorization Problem*,
  SAC 2023, LNCS pp. 369–384, DOI `10.1007/978-3-031-53368-6_18`
- preprint: IACR ePrint 2023/1562; **arXiv 2304.08718** (v3, CC-BY)
- reference implementation: `github.com/fffmath/GIFP`, by the first author

Verbatim, from arXiv v3 §3.1 (p. 7):

> **Definition 3 (GIFP(n, α, γ)).** Given two n-bit RSA moduli N₁ = p₁q₁ and
> N₂ = p₂q₂, where q₁ and q₂ are αn-bit, assume that p₁ and p₂ share γn consecutive
> bits, where the shared bits may be located in different positions of p₁ and p₂.
> The Generalized Implicit Factorization Problem (GIFP) asks to factor N₁ and N₂.

Verbatim, from arXiv v3 p. 2, which fixes what "implicit" means:

> It concerns the question of factoring two n-bit RSA moduli N₁ = p₁q₁ and
> N₂ = p₂q₂, **given the implicit information** that p₁ and p₂ share γn of their
> consecutive least significant bits, while q₁ and q₂ are αn-bit.

Four properties, each of which invalidates part of our framing:

**(a) It is a two-modulus problem.** The input is two RSA moduli simultaneously. It
does not apply to a single modulus, and therefore has no bearing on factoring
RSA-2048 as normally posed.

**(b) It requires unbalanced moduli.** Verbatim, §5 Conclusion (p. 13):

> However, this bound is valid when pᵢ and qᵢ, i = 1, 2, are **not assumed to have the
> same bit length**, i.e., N₁ and N₂ are **unbalanced moduli**.

**(c) It is heuristic.** Verbatim, §3 (p. 6):

> Since our attack in Section 3 relies on Assumption 1, it is heuristic.

Assumption 1 is algebraic independence of the Coppersmith-derived polynomials. The
authors add (p. 12) that *"in practice, it is not necessary to satisfy Assumption 1
to find the desired 'p' and 'q'"* — so the theorem is a sufficient condition under
an unproved hypothesis, and the practice is outside even that condition.

**(d) The attacker is NOT given the shared block.** This is the load-bearing point.
From the proof (p. 7):

> Proof. Without loss of generality, we can assume that the starting and ending
> positions of the shared bits are known. **When these positions are unknown, we can
> simply traverse the possible starting positions of the shared bits**, which will
> just scale the time complexity for the case that we know the position by a factor
> O(n²).

"Implicit" therefore means *the existence of a correlation is a promise; its content
and location are not given.* The attack's job is to recover the block from
(N₁, N₂) alone.

---

## 3. Our instances plant that block for us

The reference generator in `gifp.sage` (the authors' own code, lines 35, 40, 41)
draws **one** integer `share_bit` and embeds it verbatim in **both** larger primes:

```python
share_bit = ZZ(randint(2**(share_bit_length - 1)+1, 2**share_bit_length - 1))
p1 = random_blum_prime(MSB4p1*2**(gamma+beta1) + share_bit*2**(beta1_bit_length) + ..., ...)
p2 = random_blum_prime(MSB4p2*2**(gamma+beta2) + share_bit*2**(beta2_bit_length) + ..., ...)
```

**Empirical verification.** Running the authors' generator at n=800, α=0.20,
γ=0.05, β₁=0.10, β₂=0.15 and re-slicing the returned primes bit-for-bit
(`factor-scratch/r114/gifp_planted_bit_audit.sage`):

```
N1 = 800 bits   N2 = 800 bits
p1 = 640 bits   q1 = 160 bits
p2 = 640 bits   q2 = 160 bits
share_bit = 40 bits
N1 == p1*q1 ?  True        N2 == p2*q2 ?  True

offset in p1: 520, length 40
block in p1  : 1001110101110001100111010101111100011000
share_bit    : 1001110101110001100111010101111100011000
block in p2  : 1001110101110001100111010101111100011000
p1 contains share_bit verbatim : True
p2 contains share_bit verbatim : True
```

So the secret the attack is supposed to *recover* is *inserted* by the generator, and
the O(n²) position search that the paper says the attack must perform is unnecessary
because the instance family's structure makes the position known by construction.

**Our instances are therefore outside the paper's own threat model.**

---

## 4. The open problem we were chasing was published in 2024

GIFP names its own open problem verbatim (p. 4, repeated p. 13):

> There are still open problems, and the most important one is: can we improve our
> bound 4α(1 − √α) for GIFP to 2α − 2α² or even better?

That improvement exists:

> Ran Zhang, Jingguo Bi, Lixiang Li, Haipeng Peng. *An **optimal bound** for factoring
> unbalanced RSA moduli by solving Generalized Implicit Factorization Problem.*
> The Journal of Supercomputing **81**, 2024.
> DOI `10.1007/s11227-024-06478-y`

Verified via Crossref content negotiation (`"container-title": "Lecture Notes in
Computer Science"` / `"type": "book-chapter"` for the SAC paper; journal record for
this one) and OpenAlex (`cited_by_count: 0`, no open-access copy). **We did not read
the improved bound itself** — the article is paywalled. So: the improvement to GIFP's
own stated open problem is *published*, but its content is *unverified here*.

---

## 5. A live defect in the reference implementation

`gifp.sage` line 11 documents:

```python
:param alpha: The ratio of the bit length of the larger prime to the modulus bit length.
```

The code at lines 36–37 does the opposite:

```python
p_bit_length = int(modulus_bit_length * (1-alpha))
q_bit_length = int(modulus_bit_length * alpha)
```

**The code is right; the docstring is wrong.** α is the fraction of the *smaller*
prime. Any harness that read the docstring has every α inverted and every regime
mis-stated. Our own measurements recorded `|q₂| = α·n`, which agrees with the code, so
our experiments used the correct convention — but the docstring is a live trap for
anyone else who reads it, and it plausibly explains why α ≈ 0.15 looked like a wall:
it is the α at which the *collision* story and the *attack* story cross over for
planted instances.

---

## 6. What this kills, and what survives

**Killed.**

1. The premise that GIFP is a factoring method with an unknown scaling law. It is a
   two-modulus weak-keygen attack on unbalanced moduli, with a heuristic theorem.
2. The r112 n=800 "3/3 while PARI ran >4 min" result as *evidence about factoring*.
   It is a correct measurement about a synthetic planted instance. The 4.3-order
   "regime gap" to RSA-2048 was never a gap that raising n could close — it is a
   categorical difference between an attacker who has leaked/overlapping bits and an
   attacker who has nothing.
3. The "α ≥ 0.15 GIFP wall" as a statement about integer factoring. It is a boundary in
   a planted-secret regime.
4. Any expectation that scaling n produces a factoring result.

**Survives, and is the correct research question.** The weak-keygen *class* is a
legitimate target, and the paper's own motivation is a real-world one:

> we need to avoid situations where the system that creates RSA keys lack entropy.

What is needed is not a GIFP scaling law but a **characterisation of which key
generations actually produce the shared-bit condition, and at what bit lengths**. That
is a probability question about key generation, not a lattice question, and it is
open. See the companion analysis of the collision threshold.

---

## 7. Threats to validity of *this* paper

Stated in the spirit of a campaign that has shipped 16 fabricated citations:

1. **We did not read the ePrint 2023/1562 PDF.** Cloudflare served a CAPTCHA on every
   route (direct, jina proxy, landing page, archive path). All body-text quotes are
   from **arXiv v3**, which is the post-SAC revision; its abstract is demonstrably
   reworded relative to the ePrint one. We cannot exclude textual differences between
   the two.
2. **We did not read the Springer camera-ready** (paywalled), so quotes are not from
   the version of record.
3. **We did not verify the content of the 2024 improvement**, only its existence,
   title, authorship and venue. Any claim about *what* Zhang et al. proved is
   unverified and is not made here.
4. **Our empirical check is one instance** at n=800, one parameter point. The
   bit-identity of the planted block is a structural property of the generator (it is
   visible in the source lines), not a statistical claim, so a single instance
   suffices — but we did not sweep parameters.
5. **The CTF framing is partly ours.** The paper itself never mentions CTF; the
   connection is documented only in the reference repository's README, which lists
   D³CTF 2024. We therefore do **not** claim the paper is a CTF artifact. Our claim
   is the narrower and fully supported one: *our instances* are planted and therefore
   outside the paper's threat model.
6. **We do not claim GIFP is worthless.** It is a peer-reviewed theorem about a real
   weakness class. What we retract is our own use of it as a factoring method.

---

## 8. Reproduction

```bash
# Empirical: the planted block is bit-identical in both primes
/home/raver1975/sage_mamba/envs/sage/bin/sage \
    /home/raver1975/lean/factor-scratch/r114/gifp_planted_bit_audit.sage

# The generator lines that plant it
sed -n '35p;40,41p' \
    /home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage

# The docstring defect
sed -n '11p;36,37p' \
    /home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage
```

Note on the generator: `generate_gifp_instance` re-seeds and retries internally when
the bit budget is not exactly integral, logging `Regenerated seed:` lines. Our run
regenerated several times before landing on an exactly-800-bit pair. This is the trap
already recorded for this code (`gifp.sage` returns `None` for every seed unless bit
budgets land on exact integers) and it means a sweep scoring 0/0 is a *generator
refusal*, not a negative result.