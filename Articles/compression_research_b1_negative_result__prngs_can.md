# The Seed That Contains Your File Does Not Exist

There is a piece of folklore that refuses to die. It usually arrives late at night, in a chat channel, from someone who has just discovered pseudo-random number generators:

> *Random number generators produce endless streams of bits from a tiny seed. My file is just a stream of bits. So somewhere out there is a seed whose output **is** my file. Find that seed, and I have compressed a gigabyte into 64 bits.*

It is a beautiful idea. It is also, provably, impossible — not "hard", not "open", not "we do not know how yet", but impossible in the same way that you cannot fit seventeen pigeons into sixteen holes without doubling up. This article explains exactly why, exactly how much randomness *can* buy you, and why the answer is worth writing down carefully rather than waving away.

---

## The one-sentence proof

A pseudo-random number generator is a **function**. Feed it a seed, and it deterministically produces a stream. Same seed, same stream, every time — that determinism is the whole point; it is what makes simulations reproducible and stream ciphers decryptable.

Now count. If the seed is $s$ bits long, there are exactly $2^s$ possible seeds. A function has one output per input, so there are **at most $2^s$ distinct streams the generator can ever produce**. If you want to hit every one of the $2^n$ possible $n$-bit files, you need
$$2^s \ge 2^n, \qquad \text{that is,} \qquad s \ge n.$$

The seed is not shorter than the file. Ever. The generator manufactured no information; it only stirred what was already in the seed.

That is the entire argument, and everything below is an attempt to close every escape hatch a determined optimist might reach for — because the optimists are creative, and each of their escapes deserves a real refutation rather than a repetition of the slogan.

---

## Setting the stage: what "compress" means

Let us be precise, because precision is what makes the negative result durable.

Write $\{0,1\}^n$ for the set of $n$-bit strings — the files. A **decompressor** is any function $D$ that turns a finite bit string (a *program*, a *codeword*, a *compressed file*) into a file:
$$D : \{0,1\}^* \longrightarrow \{0,1\}^n .$$

That is deliberately the weakest possible assumption. $D$ can be a ZIP decoder, a neural network, a seed-expander, a brute-force search, an oracle — anything at all, of any computational cost. The **description complexity** of a file $x$ relative to $D$ is the length of the shortest program that produces it:
$$K_D(x) \;=\; \min\{\, |p| \;:\; D(p) = x \,\}.$$

This is Kolmogorov complexity with the universal machine replaced by *your* decompressor. Everything that follows holds for every $D$, so nothing depends on choosing the "right" one.

### The counting core

The engine of every result here is a single, very concrete observation. Read a bit string $p$ as a binary numeral with an extra leading $1$ prepended:
$$\nu(\varepsilon) = 1, \qquad \nu(b_1b_2\cdots b_k) = \text{the number } \overline{1b_1b_2\cdots b_k}_2 .$$
The extra $1$ is what makes the length recoverable: $2^k \le \nu(p) < 2^{k+1}$ when $|p| = k$, and distinct strings get distinct numbers. So $\nu$ is an injection from bit strings of length $\le k$ into the integers $\{1, 2, \ldots, 2^{k+1}-1\}$.

**Counting Lemma.** *For any injective code $c$ on a finite set, at most $2^{k+1} - 1$ inputs receive a codeword of length $\le k$.*

Chain this with the fact that there are $2^n$ files, and you get the classical statement in its sharpest form.

**Pigeonhole Bound.** *For every injective code $c$ on $\{0,1\}^n$, there is a file $x$ with $|c(x)| \ge n$.*

Some file always costs full price. Compression is a redistribution of description lengths, never a net reduction.

**Incompressibility Theorem.** *For every decompressor $D$ that can produce every file, some $n$-bit file has $K_D(x) \ge n$.*

The proof is a one-liner given the lemma: pick for each file a shortest program producing it. Different files must get different programs (a program has only one output), so this assignment is an injective code, and the Pigeonhole Bound applies.

---

## Escape hatch 1: "Use the seed **and** a small patch"

The first refinement anyone proposes: find the seed whose output is *closest* to my file, then store the seed plus a short list of corrections.

Formalize it generously. Let the decoder be $D(\text{seed}, p)$ — it may run the generator on `seed`, may read a side program $p$ of any nature (a correction list, a residual, a second seed, an entire second compressor), and may combine them in any way whatsoever. Let an encoder produce, for each file $x$, a pair $(\text{seed}(x), p(x))$ from which $x$ is exactly recovered.

**Seed-Plus-Side-Information Theorem.** *For some file $x$,*
$$s + |p(x)| \;\ge\; n .$$

*Proof sketch.* Concatenate: write out the $s$ seed bits followed by the program bits, giving a single codeword $c(x)$. Because the seed has *fixed* length $s$, the concatenation is unambiguously splittable, so $c$ is injective. Apply the Pigeonhole Bound. $\square$

The total bill — seed plus patch — is at least $n$ bits for some file. The generator contributed nothing beyond the $s$ bits used to *name* its seed.

## Escape hatch 2: "Chain several generators"

Feed one generator's output into another's seed. Surely the composition covers vastly more ground?

**Composition Theorem.** *If $G_2 \circ G_1$ reaches every $n$-bit file from an $s$-bit seed, then $s \ge n$ — regardless of how large the intermediate state space is.*

The composition is still a function of the original seed. Widening the pipe in the middle does not widen the entrance. The shortest link in the chain rules.

## Escape hatch 3: "Keep a library of generators and use the lucky one"

This is the most seductive escape, and it deserves the most care. Maintain $2^m$ different generators; for each file, use whichever one happens to fit.

**Generator-Library Theorem.** *If among $2^m$ generators, each with $s$-bit seeds, some pair (generator, seed) reaches every $n$-bit file, then $m + s \ge n$.*

Choosing a generator is itself information: you must record *which* one you used, and that costs $m$ bits. The theorem says the library buys you exactly those $m$ bits and not one bit more.

And there is a much stronger version, which is where the analysis stops being routine. One might hope that although no single generator handles everything, *every file is easy for some member of the library* — hardness spread thinly across the library rather than concentrated. It is not so.

**Uniform Hardness Theorem.** *Given any library of $2^m$ decompressors $D_i$, each able to produce every file, there exists a single file $x$ such that*
$$n \;\le\; m + K_{D_i}(x) \qquad \text{for } \textbf{every } i .$$

One file, simultaneously hard for the entire library.

*Proof sketch.* Build a **universal machine for the library**: a decompressor $U$ that reads $m$ index bits, then runs the selected member on the rest of the program. Then $K_U(x) \le m + K_{D_i}(x)$ for every $i$ — the *invariance principle*, whose general form says that if one decompressor can simulate another after reading a fixed prefix $q$, then $K_D(x) \le |q| + K_{D'}(x)$. Now apply the Incompressibility Theorem to $U$ itself: some file has $K_U(x) \ge n$. Pushing that back through the invariance inequality gives $n \le m + K_{D_i}(x)$ for every single $i$. $\square$

The moral is worth stating plainly: **searching a space of compressors is itself a description**, and the search costs precisely what it takes to write down the answer to the search.

## Escape hatch 4: "Beat it on average, not in the worst case"

Fine, says the optimist: some file is incompressible, but who cares about the adversarial worst case? What matters is the average over real data.

Two results close this.

**Rare-Win Theorem.** *For every decompressor, the fraction of $n$-bit files whose description shrinks by $d$ bits or more is at most $2^{1-d}$.*

Read that with real numbers. Saving one byte — $d = 8$ — works for at most one file in $128$. Saving two bytes, at most one in $32{,}768$. Saving a kilobyte works for a fraction below $2^{-8000}$, a number with no physical meaning. Compression schemes that work in practice are not violating this; they are exploiting the fact that the files people actually store are a vanishingly thin, highly structured sliver of $\{0,1\}^n$.

**Average-Rate Theorem.** *For every injective code on $\{0,1\}^n$ and every $k < n$, the mean codeword length satisfies*
$$\frac{1}{2^n}\sum_{x} |c(x)| \;\ge\; (n-k)\left(1 - 2^{-k}\right).$$

Choosing $k \approx \log_2 n$ makes the right side $n - O(\log n)$. On uniformly random data, *no* scheme — PRNG-based or not — achieves an average rate meaningfully below $n$ bits per file. The same bound holds verbatim for description complexity relative to any decompressor.

---

## The other side of the coin: what a generator *can* do

A purely negative result is only half the calibration. What exactly does the seed trick buy?

**Small-Set Coding Theorem.** *Any set of at most $2^k$ files carries an injective code of length exactly $k$.*

Combined with the observation that a generator with an $s$-bit seed has at most $2^s$ outputs, this gives the positive half precisely:

**PRNG Dichotomy.** *Fix a generator $G$ with $s$-bit seeds producing $n$-bit files, with $s + 1 < n$. Then:*
1. *the set of outputs of $G$ — at most $2^s$ files — admits an injective $s$-bit code; the "compress to the seed" trick works perfectly there; and*
2. *there is a file $x$ that the best PRNG-powered compressor still needs $n$ bits for, and no seed produces $x$ at all.*

That is the complete answer to "can a generator help?": **it helps exactly on the files it already generates, and nowhere else.** It is not a compressor; it is a *decompressor for one very particular family of files* — and those files always had short descriptions anyway. The generator is not creating compressibility, it is revealing compressibility that was there by construction.

### The demonstration, made concrete

Here is the honest version of the seed trick, spelled out as an actual compressor. Given a generator $G$, define a decompressor $H$ that reads one flag bit:

- flag $\mathtt{0}$ — *seed mode*: the next $s$ bits are a seed; output $G(\text{seed})$;
- flag $\mathtt{1}$ — *literal mode*: the next $n$ bits are the file; copy them out.

This is the best possible "compress to the seed" scheme, and its behaviour is exactly as advertised, in both directions:

- **It genuinely wins.** Every output of $G$ has $K_H \le s+1$: one flag bit plus the seed, no matter how large $n$ is. A gigabyte of generator output really does collapse to 65 bits.
- **It never loses.** Every file has $K_H \le n+1$: at worst one wasted flag bit. The scheme is safe.
- **It cannot win in general.** As soon as $s + 1 < n$, there is a file with $K_H \ge n$ — and that file is provably not in the range of $G$.
- **The win is rare.** At most $2^{s+2}$ of the $2^n$ files enjoy the shortcut: a fraction of $2^{s+2-n}$.

All four statements are true simultaneously, and together they are the whole story. Notice the shape of the trade: the flag bit costs one bit on *every* file in order to save $n - s - 1$ bits on a $2^{s+2-n}$ fraction of them. The expected saving is negative, exactly as the Average-Rate Theorem demands.

### A generator you can check by hand

Take the linear congruential generator $x \mapsto 5x + 3 \bmod 16$ on a 4-bit seed, and read out two successive states as an 8-bit value:
$$\mathrm{out}(\text{seed}) \;=\; g(\text{seed}) \;+\; 16 \cdot g(g(\text{seed})), \qquad g(x) = 5x+3 \bmod 16 .$$

Sixteen seeds, $256$ possible 8-bit outputs. Enumerate them: the generator hits exactly $16$ values, and **$240$ of the $256$ are unreachable** — no seed produces them, no amount of searching will find one. The value $0$, for instance, is simply not in the image.

This tiny example is the whole phenomenon in miniature. Scale $16$ to $2^{64}$ and $256$ to $2^{8 \times 10^9}$, and the ratio does not improve; it becomes unimaginably worse. The set of files reachable from a 64-bit seed is a set of measure $2^{-7999999936}$ inside the space of one-gigabyte files. "Search for the seed" is not a hard search. It is a search whose target, with overwhelming probability, does not exist.

---

## Why bother proving what everyone "knows"

Three reasons.

**First, the folklore version is imprecise in ways that matter.** "You can't compress random data" is often stated and rarely quantified. The results above are quantitative: at most $2^{1-d}$ of files shrink by $d$ bits; a library of $2^m$ compressors buys exactly $m$ bits; the average rate is $n - O(\log n)$. Those numbers are what let you tell an engineer *how much* effort a proposal is worth before they spend a year on it.

**Second, the escapes are not obviously blocked.** "Seed plus patch" and "library of generators" are genuinely reasonable-sounding, and the reason they fail — that specifying which patch, or which generator, is itself information that must be paid for — is a real argument, not a slogan. The Uniform Hardness Theorem in particular is not something one should accept without proof: it asserts something strictly stronger than "each generator has a hard file", namely that one file is hard for all of them at once.

**Third, the bound is tight, and tightness is where the useful engineering advice lives.** The Small-Set Coding Theorem says $k$ bits describe $2^k$ objects — no more, and no fewer. So the productive question is never "how do I compress everything?" but "what is the *small set* my data actually lives in, and can I name its members cheaply?" That reframing is the entire content of practical compression: JPEG is a claim about which images occur, a language model is a claim about which token sequences occur. The pigeonhole bound does not forbid compression; it tells you that all compression is a bet on structure, and it charges you exactly $\log_2(\text{number of possibilities})$ bits when the bet is right.

---

## Coda: randomness is not a resource here

There is a temptation to see randomness as a kind of raw material — something you can mine for information. The results above say the opposite, and say it sharply. A deterministic generator's entire information content sits in its seed. Running it is a *data-processing* step, and data processing never increases description complexity: post-composing any decompressor with any function can only leave complexity where it was or lower it, never raise it. But lowering complexity for a few strings is precisely what the counting bound has already accounted for, because the counting argument never inspects the decompressor at all. It looks only at how many short programs exist.

That last point is the deepest one, and it is why no cleverness will ever overturn the conclusion. The proof does not care whether your decompressor is a generator, a neural network, a physical process, or something not yet invented. It cares only that programs are finite bit strings and that there are not enough short ones to go around. Any future scheme, of any computational power, will be counted by exactly the same argument.

Sixteen holes. Seventeen pigeons. No amount of pseudo-randomness will change the count.
