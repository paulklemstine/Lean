# The Dial That Wasn't There

## How higher reciprocity laws escape periodicity — and still tell you nothing new

### A secret hidden in plain arithmetic

Suppose someone hands you a large number $N$ and tells you it is the product of two secret primes, $N = pq$. You want $p$. The obvious route — factor $N$ — is the problem the whole world's public-key cryptography is betting you cannot take. So you look for a side door.

Number theory is full of tempting side doors, and the most famous of them is the *quadratic residue symbol*. Fix a small base, say $a = 2$, and ask a yes/no question about the secret prime $p$:

> Is $2$ a perfect square modulo $p$? That is, does the congruence $x^2 \equiv 2 \pmod p$ have a solution?

This looks like it should require knowing $p$. It does not — or rather, it requires astonishingly little about $p$. Gauss's second supplement to the law of quadratic reciprocity says:

$$2 \text{ is a square mod } p \iff p \equiv 1 \text{ or } 7 \pmod 8 .$$

Nothing about $p$ matters except its remainder on division by $8$. Three bits of $p$ — barely that — decide the question completely. It is the arithmetic equivalent of a **dial**: a knob with $8$ positions, and once you know which position $p$ sits in, the answer is fixed forever.

Dials are wonderful and dials are useless, and they are both for the same reason. A dial is a *periodic* function of the secret. It repeats with period $8$, or $4|D|$, or whatever the conductor happens to be. So a dial can distinguish at most as many secrets as it has positions. If you already know $p \bmod 8$ — and in many attack scenarios you are handed exactly such partial information for free — the symbol tells you nothing you did not have. If you do not know $p \bmod 8$, the symbol tells you exactly $\log_2 8 = 3$ bits, and not one bit more, no matter how enormous $p$ is. A dial's information content is capped by its conductor. That is the whole story of the quadratic channel: *hint-computable or informative, never both*.

So the natural next move is to reach past Gauss. Quadratic reciprocity is the first of a tower of reciprocity laws — cubic, quartic, and beyond — discovered by Gauss, Jacobi, and Eisenstein, and living not in the ordinary integers but in the *Eisenstein integers* $\mathbb{Z}[\omega]$ (where $\omega = e^{2\pi i/3}$) and the *Gaussian integers* $\mathbb{Z}[i]$. Their symbols are strictly richer objects. And crucially — this is the whole point of the story — they are **not periodic**.

### The escape is real

Here is the cubic analogue of Gauss's question. Let $p \equiv 1 \pmod 3$, so that the multiplicative group modulo $p$ has order divisible by $3$ and cubes form a proper subgroup. Ask:

> Is $2$ a perfect cube modulo $p$?

Gauss himself found the answer, and it is one of the most beautiful theorems in elementary number theory:

$$2 \text{ is a cube mod } p \iff p = x^2 + 27y^2 \text{ for integers } x, y.$$

Compare the two criteria. Quadratic: a condition on $p \bmod 8$. Cubic: a condition on whether $p$ is represented by a particular quadratic form. The second is *not* a congruence condition, and the reason is structural. Squares live in the abelian world; the splitting behaviour that governs cubes lives in the field $\mathbb{Q}(\sqrt[3]{2}, \omega)$, whose Galois group is the non-abelian symmetric group $S_3$. Class field theory says congruence conditions detect exactly abelian splitting. A non-abelian condition cannot be a dial. Cubic residuacity genuinely escapes the periodic world.

Escape claims deserve witnesses rather than philosophy, so here is the escape made concrete. Let

$$720720 = \mathrm{lcm}(1, 2, 3, \ldots, 16),$$

a modulus so rich that every small period anyone might hope to find divides it. Now take the two primes

$$p = 43, \qquad q = 720763 = 43 + 720720 .$$

They are congruent modulo $720720$, hence modulo *every* divisor of it: modulo $8$, modulo $9$, modulo $16$, modulo $5 \cdot 7 \cdot 11 \cdot 13$ — modulo everything in that range. Both are $\equiv 1 \pmod 3$, so the cubic question is meaningful for both. And their answers differ:

- $2$ **is** a cube modulo $43$: $20^3 = 8000 = 186 \cdot 43 + 2$. (Consistently, $43 = 4^2 + 27 \cdot 1^2$.)
- $2$ is **not** a cube modulo $720763$: the cubic symbol $2^{(720763-1)/3} = 2^{240254} \equiv 632375 \not\equiv 1$. (Consistently, $720763$ has no representation $x^2 + 27y^2$.)

That single pair of primes kills every hope of periodicity at any modulus in the range: no rule of the form "look at $p \bmod M$, then decide" can possibly be correct for $M$ dividing $720720$, because the two primes present the identical input and demand opposite outputs. And this is not a quibble about a particular formalism — it holds for *any* statistic whatsoever, valued in *any* set, that depends on $p$ only through $p \bmod M$, followed by *any* decision rule you like. The information simply is not there.

The quartic channel escapes the same way, with its own witness pair: $137$ and $720857 = 137 + 720720$. Modulo $720857$, the number $2$ is a fourth power — $96769^4 \equiv 2$ — while modulo $137$ it is not, since $2^{(137-1)/4} = 2^{34} \equiv 136 \not\equiv 1$.

So the cubic and quartic channels are free of the cage that holds the quadratic one. Now comes the disappointment.

### The escape buys nothing

Break the question into two. *What does a symbol cost to compute?* And *what does a symbol tell you once computed?*

**The cost is circular.** There are exactly two known routes to the cubic bit of $p$. The first is Euler's: raise $2$ to the power $(p-1)/3$ modulo $p$ and see whether you land on $1$. This is fast — but read the exponent. It is $(p-1)/3$. You cannot form it without already knowing $p$, and $p$ is precisely the secret you were trying to learn. The second route is Gauss's: find the representation $p = x^2 + 27y^2$. Also fine — but finding such a representation for the *hidden* factor of $N$ is a factoring-strength problem. Both roads lead back to the secret. The escape from periodicity is exactly what closes both doors: because the answer is *not* determined by $p \bmod M$ for any small $M$, the cheap congruence route that made the quadratic symbol computable simply does not exist. Escape and inaccessibility are two faces of the same theorem.

There is a third route one might try — computing modulo $N$ itself rather than modulo $p$. It fails for a different reason, and the reason is a clean piece of algebra. Being a $k$-th power modulo $N = mn$ (with $m, n$ coprime) is *equivalent* to being a $k$-th power modulo $m$ **and** modulo $n$. The predicate factors through the Chinese Remainder Theorem into a conjunction. But a conjunction is symmetric: swapping the two factors leaves it unchanged. So any higher-power datum computable from $N$ alone is a function of the *unordered* pair $\{p, q\}$ — and a symmetric function can never single out one factor. That is a genuine barrier, not a failure of imagination.

**And the payload is capped.** Suppose you waved all that away and were simply *given* the symbols. How much would they be worth?

Here the answer is a hard ceiling, and it is the same ceiling for every exponent. Whatever the reciprocity law, the usable, secret-independent read-out of a symbol is a single **bit**: residue, or not. Read $K$ bases and you get a $K$-bit fingerprint, which takes at most $2^K$ distinct values. So a fingerprint can separate at most $2^K$ candidates, and pinning down $C$ candidates costs at least $\log_2 C$ symbols. The bound does not mention $k$. Cubic capacity equals quartic capacity equals quadratic capacity: $2^K$.

Is the ceiling real, or is it a vacuous bound on an empty channel? It is attained. The two cubic bits at bases $2$ and $3$ take all four possible patterns on the four primes $7, 31, 61, 307$:

| $p$ | $2$ a cube? | $3$ a cube? |
|---|---|---|
| $7$ | no | no |
| $31$ | yes | no |
| $61$ | no | yes |
| $307$ | yes | yes |

Two symbols really do separate $2^2 = 4$ candidates — and, by the ceiling, never five. The channel is exactly as wide as advertised, and no wider.

In fact the higher channel is slightly *worse* per symbol, for a reason that is almost embarrassing in its simplicity. Among the $p-1$ invertible residues modulo a prime, exactly $(p-1)/k$ are $k$-th powers. Half the residues are squares; only a *third* are cubes. A fair coin carries one bit; a coin that lands heads a third of the time carries about $0.918$ bits. The cubic bit is biased, hence individually less informative than the quadratic bit. Raising the exponent buys a wilder symbol and a *poorer* bit.

### The mirage of "68 out of 68"

The experiment that motivated all this reported a striking-looking number. Take the $68$ primes between $1000$ and $2000$ that are $\equiv 1 \pmod 3$, and fingerprint each one with five bases $2, 3, 5, 7, 11$. Using the full cubic symbol values, all $68$ fingerprints come out distinct — a perfect separation! Using the full quadratic symbol values, also $68$ out of $68$. Doesn't that mean a handful of symbols pins down a prime?

No — and understanding why is the punchline of the whole investigation. The *value* $2^{(p-1)/3} \bmod p$ is a residue class modulo $p$. It lives in a set whose very description contains $p$. Of course such a "fingerprint" separates all $68$ primes: it has $p$ baked into it. That is not leakage; that is circularity in numerical costume.

Strip away the circularity — record only the secret-independent read-out, the residuacity bit — and the mirage evaporates:

| fingerprint (five bases) | distinct values among the 68 primes | ceiling |
|---|---|---|
| full quadratic symbol values | 68 / 68 | (values live modulo $p$ — encodes $p$) |
| full cubic symbol values | 68 / 68 | (same artefact) |
| quadratic residuacity **bits** | 31 / 68 | $2^5 = 32$ |
| cubic residuacity **bits** | 23 / 68 | $2^5 = 32$ |

Both channels bump against $32$. The quadratic bits nearly saturate it; the cubic bits, being sparser and more biased, do worse. There is no higher-power advantage anywhere in this table.

### Transverse, but not stronger

One last hope deserves burial. If the cubic bit is not a congruence datum, might it at least be *new* — information the quadratic channel does not already contain? Yes: the two channels are genuinely transverse. All four combinations of (is $2$ a square? is $2$ a cube?) occur among primes $\equiv 1 \pmod 3$: $7$ (square, not cube), $13$ (neither), $31$ (both), $43$ (cube, not square). Neither bit is a function of the other, in either direction.

But transverse is not the same as stronger. Combine everything an attacker could dream of — a partial hint $p \equiv r \pmod m$ obtained from some side channel, a whole system of $L$ periodic dials with combined conductor $M^*$, and $K$ higher-power residuacity bits at arbitrary bases — and some single joint reading is still shared by at least

$$\frac{|\Omega|}{\bigl(M^*/\gcd(M^*,m)\bigr) \cdot 2^K}$$

of the candidates $\Omega$: that many secrets remain perfectly indistinguishable. The higher-power channel enters this bound only through the factor $2^K$ — the contribution of *any* $K$ bits from *any* source. Escaping periodicity relabels which bits you read. It does not create bits.

### What the verdict means

The result is negative, and negative results of this shape are what make a research programme honest. The higher-power reciprocity channel was a genuinely reasonable idea: the symbols are richer, the laws are deeper, the criteria are non-abelian. Each of those hopes is *true*. And each of them, followed to its end, closes rather than opens the door:

- The channel escapes periodicity — which is precisely why no cheap congruence shortcut computes it.
- The symbol is computable — via an exponent that presupposes the secret.
- The alternative criterion is elegant — and requires a representation whose discovery is factoring-hard.
- The composite-modulus version is computable — and symmetric in the two factors, so it cannot name one.
- The fingerprint is informative — up to exactly $2^K$, the same as quadratic, with an individually poorer bit.

The information content of the residue channel, then, is fully accounted for: a *dial* part, determined by the secret's residue modulo a small conductor and therefore already free to anyone with a partial hint; plus *fine-arithmetic noise*, real and non-periodic and genuinely new — but reachable only by a computation that begins with the answer. Between the two there is nothing. No new polynomial-time handle hides in cubic or quartic reciprocity.

There is a certain beauty in a door that is locked by its own architecture. The very non-abelian richness that makes cubic reciprocity a deeper theorem than Gauss's — the $S_3$ symmetry of $\mathbb{Q}(\sqrt[3]{2}, \omega)$, the quadratic form $x^2 + 27y^2$, the escape from every congruence class — is the same richness that puts the symbol out of computational reach. Escape from periodicity is not a gain in information. It is a change of prison.
