# The Library of Babel, Counted Exactly

## A library that contains everything

In 1941, Jorge Luis Borges imagined a library so complete that it left nothing out. Its hexagonal galleries stretched in every direction, and on their shelves stood every book that could ever be written — not the good ones, not the famous ones, but *all* of them. Every novel, every refutation of every novel, every grocery list, every biography of every person who never lived, every page of pure gibberish. Somewhere in the Library of Babel sits the true history of your life, and next to it ten thousand near-copies with a single wrong date.

Borges fixed the format precisely. Each book has $410$ pages, each page $40$ lines, each line $80$ characters, drawn from an alphabet of $25$ symbols. That makes $410 \times 40 \times 80 = 1{,}312{,}000$ characters per volume, and the number of distinct volumes is

$$25^{1312000}.$$

This is a finite number. It is also one of the most violently large finite numbers ever to appear in literature — far more than the number of atoms in the observable universe, which is a mere $10^{80}$ or so. The Library is complete, finite, and physically impossible. And that tension — *everything exists, yet nothing can be found* — is the engine of Borges' story.

What follows is an attempt to take Borges at his word and treat the Library as a genuine mathematical object: a finite probability space. Once you do, the haunting questions of the story turn into questions you can actually answer with numbers. How likely is a random book to contain a particular sentence? How many copies of a given paragraph should you expect to stumble across? What does it really cost to "find meaning" in a sea of noise? The answers are clean, exact, and — once you see them — strangely consoling.

## From shelves to functions

To count anything, we first need to say precisely what a book *is*. Strip away the paper and the hexagons. A volume of length $L$ over an alphabet of $b$ symbols is nothing more than a rule that assigns, to each of the $L$ positions, one of the $b$ symbols. In mathematical language, a volume is a function

$$v : \{0, 1, \dots, L-1\} \to \{0, 1, \dots, b-1\}.$$

The **Library** is then simply the collection of *all* such functions. Borges' particular library is the case $b = 25$, $L = 1312000$, but nothing in the mathematics cares about those specific numbers; the same reasoning works for an alphabet of $2$ symbols and books of length $3$, which you can check by hand.

The very first fact is the one Borges asserts and never proves:

> **The Library has exactly $b^L$ volumes.**

The argument is the oldest trick in combinatorics. Build a book one position at a time. The first position can be any of $b$ symbols; so can the second, independently; and so on through all $L$ positions. Multiply the independent choices and you get $b \times b \times \cdots \times b = b^L$. For Borges' constants this is the $25^{1312000}$ that opens the story. The point is not the size — it is that the size is *exactly* a power, with no fudge factor, no approximation, no "roughly." The Library is a perfectly regular object.

## Every book is equally unlikely

Now we add chance. Imagine reaching blindly into the Library and pulling out a single volume, with no volume favored over any other. This is the **uniform distribution**: each of the $b^L$ books is equally probable. The probability of any one particular book — say, the one you are reading right now, transcribed letter for letter — is therefore

$$\frac{1}{b^L} = b^{-L}.$$

For Borges' library that is $25^{-1312000}$, a number so close to zero that writing out its decimal expansion would itself fill a fair stretch of the Library. This is the precise sense in which any *specific* book is a miracle: not impossible, just overwhelmed. And note the democracy of it. The collected works of Shakespeare and a book consisting solely of the letter "M" repeated $1{,}312{,}000$ times are *exactly* as probable. The Library has no taste. Meaning is something we bring to it, not something it contains in greater concentration anywhere.

## The real question: how often does a phrase appear?

Single books are too rare to be interesting. The lived experience of the Library is different: you are not hunting for one exact volume, you are scanning for a *phrase* — a recognizable fragment of sense embedded anywhere inside a book. "O time thy pyramids." A valid theorem. Your own name. So the sharp question becomes: **if I fix a short pattern, how many times should I expect it to appear inside a random volume?**

Here is where the counting becomes genuinely beautiful. Fix a pattern of length $k$ — a specific string of $k$ symbols. A book of length $L$ has $L - k + 1$ places where a length-$k$ window can begin: starting at position $0$, at position $1$, and so on until the window's tail reaches the last character. At each such starting position, the pattern either matches or it doesn't.

What is the chance of a match at one fixed position? The $k$ characters in that window must all agree with the pattern, and each character independently has probability $1/b$ of being the right symbol. So a single window matches with probability $b^{-k}$ — and, crucially, this probability does not depend on *where* the window sits.

Now comes the one idea that makes expectation so powerful: **linearity**. The expected total number of matches is just the sum, over all $L - k + 1$ windows, of the probability that each individual window matches. Linearity of expectation works even though the windows overlap and are tangled together in complicated ways — we never need them to be independent. Adding up identical terms gives the central formula of this work:

$$\mathbb{E}[\text{number of occurrences of the pattern}] = (L - k + 1)\, b^{-k}.$$

Let that sink in. The expected count of a phrase is the number of slots it could occupy, discounted by the rarity $b^{-k}$ of filling any one slot correctly. It is the kind of formula that feels obvious *after* you see it and impossible *before*.

A worked example makes it vivid. Take an English-sized alphabet, $b = 26$, and ask for the four-letter word "MATH", so $k = 4$, in a book the size of a long novel, say $L = 1{,}000{,}000$ characters. Then the expected number of appearances is

$$(1000000 - 4 + 1)\cdot 26^{-4} = 999997 \times \frac{1}{456976} \approx 2.19.$$

So a million-character random book contains, on average, *about two* copies of "MATH" — not zero, not a thousand, but two. The Library is not as empty of meaning as it first appears; short fragments of sense are everywhere. It is only the *long* coherent stretches that vanish into the $b^{-k}$ abyss as $k$ grows.

## The price of meaning grows exponentially

That last remark is the moral of the whole subject, and the formula states it exactly. The expected number of occurrences carries the factor $b^{-k}$. Every additional symbol you demand of your pattern divides the expected count by $b$. Ask for a $5$-letter word instead of a $4$-letter one and matches become $26$ times rarer; ask for a sentence and they become astronomically rarer; ask for a coherent page and you have left the realm of any conceivable search.

This is the mathematical heart of Borges' despair. The Library contains every truth, but truth is *long*, and length is punished exponentially. The librarians of the story wander for generations precisely because the thing they seek — a single meaningful book — has a length $k$ so large that $(L-k+1)\,b^{-k}$ is, for all practical purposes, zero.

## An honest ceiling on finding a phrase at all

The expectation tells you the average number of copies, but a wanderer cares about something slightly different: the probability that a phrase appears *at least once* in a book. That is harder, because the events "the phrase appears at position $i$" overlap and interfere. But there is a clean and rigorous *upper bound*, and it follows from a principle as old as counting itself: the chance that *something* in a list happens is never more than the sum of the chances of each item. (If you double-count the overlaps, you can only overshoot.) This is the **union bound**, and applied here it gives

$$\mathbb{P}[\text{the pattern appears somewhere}] \;\le\; (L - k + 1)\, b^{-k}.$$

The same expression that counted the *average* number of occurrences also *caps* the probability of *any* occurrence. When the average number of copies is small, the chance of even one copy is at most that small number — so a phrase you expect to see $0.001$ times will appear with probability at most one in a thousand. The bound is honest in the other direction too: when the right-hand side exceeds $1$ it tells you nothing new, exactly as it should, because a probability can never exceed $1$ and the bound politely declines to claim otherwise.

## The edge cases that keep the theory honest

A theory that only works for "nice" inputs is a theory waiting to embarrass you. Part of the work here is making sure every degenerate case behaves.

What if the alphabet is *empty*, $b = 0$? Then there are no symbols, no books can be written (for $L > 0$ there is literally no way to fill the first position), and the Library is empty: $0^L = 0$. The probability formulas, which divide by the size of the Library, gracefully refuse to assert anything about an empty world — which is why the expectation result quietly requires at least one symbol, $b \ge 1$.

What if the alphabet has *exactly one* symbol, $b = 1$? Then there is only one possible book — a monotonous string of the lone symbol — and indeed $1^L = 1$. The Library collapses to a single shelf.

What if the pattern has *length zero*, $k = 0$? The empty pattern matches everywhere, trivially, and the formulas reflect that with $b^{0} = 1$. And the boundary case $k = L$, a pattern as long as the entire book, leaves exactly $L - k + 1 = 1$ possible position, as it must.

None of these are afterthoughts. They are the stress tests that distinguish a slogan from a theorem. The results stated above hold in every one of these corners.

## What the Library teaches

Borges' Library is usually read as a parable of futility: total information, zero usable knowledge. The counting tells a subtler story.

First, the Library is *not* mysterious. It is a finite set of size exactly $b^L$, with a uniform distribution in which every book has probability exactly $b^{-L}$. There is no fog here, only a very large, very regular object.

Second, meaning is not absent — it is *priced*. Short patterns are abundant; the expected number of copies of a $k$-symbol phrase is precisely $(L-k+1)\,b^{-k}$. You will trip over four-letter words. The catastrophe is reserved for *long* coherence, where the exponential $b^{-k}$ crushes the linear count of available positions.

Third, and most practically, the union bound $(L-k+1)\,b^{-k}$ gives a usable guarantee: it tells you, before you ever start searching, how unlikely you are to find what you seek. In that sense the mathematics *is* the catalog Borges' librarians lacked — not a map to the one true book, but an exact accounting of the odds against it.

Every possible text already exists. What the counting provides is the one thing the Library itself withholds: a precise, finite, honest measure of how hard meaning is to find. And that, it turns out, is something you can write down in a single line.
