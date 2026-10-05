**Title:** FACT r114: GIFP is NOT a factoring method — it is a two-modulus weak-keygen attack, our instances are PLANTED, and its open problem was published in 2024

**Labels:** approved-direction

---

## The retraction

Rounds 110–113 treated **GIFP** as a novel factoring method with an unknown scaling
law toward RSA-2048, and recorded one live positive:

> GIFP recovers `p₂` at n=800 in 3/3 while PARI `factor(N)` on the same instance ran
> >4 minutes without success. — r112

**That result is a correct measurement about a synthetic instance the experiment
itself builds. It is not evidence about factoring, and the scaling question it
generated was ill-posed.**

## 1. GIFP = Generalized *Implicit* Factorization Problem

Feng, Nadi, Pietrzak, *Solving the Generalized Implicit Factorization Problem*, SAC
2023, LNCS pp. 369–384, DOI `10.1007/978-3-031-53368-6_18`; ePrint 2023/1562;
arXiv 2304.08718. Verbatim, arXiv v3 §3.1 (p. 7):

> **Definition 3 (GIFP(n, α, γ)).** Given two n-bit RSA moduli N₁ = p₁q₁ and
> N₂ = p₂q₂, where q₁ and q₂ are αn-bit, assume that p₁ and p₂ share γn consecutive
> bits, where the shared bits may be located in different positions of p₁ and p₂.
> … asks to factor N₁ and N₂.

So it is **two moduli at once**, it needs **unbalanced** primes (p.13: *"N₁ and N₂
are unbalanced moduli"*), and it is **heuristic** (p.6: *"Since our attack in
Section 3 relies on Assumption 1, it is heuristic."*).

## 2. Our instances plant the secret the attack is supposed to recover

The attacker is **not** given the shared block — that is what "implicit" means (p.2:
*"given the implicit information that p₁ and p₂ share γn of their consecutive least
significant bits"*). It must recover it, traversing an O(n²) position grid (p.7).

But the reference generator `gifp.sage` (the authors' own code) embeds one
`share_bit` integer **verbatim into both** larger primes:

```python
share_bit = ZZ(randint(2**(share_bit_length-1)+1, 2**share_bit_length-1))
p1 = random_blum_prime(MSB4p1*2**(gamma+beta1) + share_bit*2**(beta1_bit_length) + ...)
p2 = random_blum_prime(MSB4p2*2**(gamma+beta2) + share_bit*2**(beta2_bit_length) + ...)
```

Verified empirically by running the authors' generator at n=800, α=0.20, γ=0.05 and
re-slicing the primes:

```
share_bit = 40 bits, offset 520
block in p1  : 1001110101110001100111010101111100011000
share_bit    : 1001110101110001100111010101111100011000
block in p2  : 1001110101110001100111010101111100011000
p1 contains share_bit verbatim : True
p2 contains share_bit verbatim : True
```

**Our instances are outside the paper's own threat model.**

## 3. The open problem was already solved

GIFP names its own open problem (p.4, p.13): *"can we improve our bound 4α(1−√α)
for GIFP to 2α−2α² or even better?"* That is:

> Ran Zhang, Jingguo Bi, Lixiang Li, Haipeng Peng. *An **optimal bound** for factoring
> unbalanced RSA moduli by solving Generalized Implicit Factorization Problem.*
> **J. Supercomputing 81** (2024). DOI `10.1007/s11227-024-06478-y`

Existence verified via Crossref + OpenAlex; **the improved bound itself is paywalled
and we did not read it.**

## 4. A live defect in the reference code

`gifp.sage:11` documents `alpha` as *"the ratio of the bit length of the **larger**
prime"*, but `gifp.sage:36-37` computes `p = (1-alpha)*n`, `q = alpha*n`. **The
docstring is wrong.** Our runs used the code's convention (`|q₂| = α·n`, matching the
r112 measurement), but anyone reading the docstring has every α inverted.

## What this kills

- GIFP as a factoring method with an open scaling law.
- The n=800 "3/3 vs PARI >4 min" result as evidence about factoring.
- The "α ≥ 0.15 GIFP wall" as a statement about integer factoring — it is a boundary in
  a planted-secret regime.
- The 4.3-order "regime gap" to RSA-2048 as something raising n could close.

## What survives

The weak-keygen **class** is legitimate; the paper's own motivation is
*"we need to avoid situations where the system that creates RSA keys lack entropy."*
The correct research question is not a GIFP scaling law but:

> **Which real key generations actually produce the shared-bit condition, and at what
> bit lengths?**

That is a probability question about key generation — two independently generated
(1−α)n-bit primes share any window of length w with probability ≈ (number of
windows)·2^(−w), so sharing becomes impossible once w ≳ log₂(n). At n=2048 the
attack's required shared block 4α(1−√α)·n is a fixed *fraction* of n, orders of
magnitude above that threshold. Companion analysis in progress.

## Threats to validity

1. The **ePrint PDF was never accessed** (Cloudflare CAPTCHA on every route). All
   quotes are from arXiv v3, the post-SAC revision, whose abstract is reworded.
2. The **Springer camera-ready was not read** (paywalled).
3. The **content of the 2024 improvement is unverified** — only its existence, title,
   authorship and venue.
4. The empirical check is **one instance, one parameter point**. The planted block is
   a structural property visible in the generator source, so one instance suffices.
5. The **paper never mentions CTF**; that framing comes from the reference repo's
   README (D³CTF 2024). We therefore make the narrower claim: *our* instances are
   planted and outside the threat model.
6. **We do not claim GIFP is worthless.** It is a peer-reviewed theorem about a real
   weakness class. What is retracted is our use of it as a factoring method.

## Reproduction

```bash
/home/raver1975/sage_mamba/envs/sage/bin/sage \
    /home/raver1975/lean/factor-scratch/r114/gifp_planted_bit_audit.sage
sed -n '35p;40,41p' /home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage
sed -n '11p;36,37p' /home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage
```

Full paper: `factor-scratch/r114/papers/R114_gifp_retraction.md`