Coursera Data Science Capstone Project
========================================================
author: Jeremy Bowyer
date: 1/1/2017
autosize: true
font-family: 'Helvetica'
css: custom.css

This presentation will pitch my text prediction application, created as the capstone project for the Johns Hopkins Cousera Data Science Specialization, with cooperation from SwiftKey.



The Goal & Corpus Creation
========================================================
<small>
The goal of the application is to take a text phrase provided by the user and compare that to a large text corpus to predict the user's next word.

This will be done using a combination of the [Katz Backoff](https://en.wikipedia.org/wiki/Katz's_back-off_model) method, in conjuction with [Good-Turing frequency estimation](https://en.wikipedia.org/wiki/Good%E2%80%93Turing), and a couple of custom tweaks. 

The training set is sampled from 3 large text corpora, each one coming from a different source: Twitter, blog posts, and new stories. The full dataset can be found [here](https://d396qusza40orc.cloudfront.net/dsscapstone/ dataset/Coursera-SwiftKey.zip). 

I take a sample of each corpus, clean them by removing things like special characters, profanity, numbers, etc., then take those cleaned samples and [tokenize](https://en.wikipedia.org/wiki/Tokenization_%28lexical_analysis%29) them, extracting 1-gram, 2-gram, 3-gram and 4-gram phrases and storing them in their appropriate n-gram lookup tables.
</small>

The Algorithm
========================================================

<small>As mentioned before, I am using the <a href="https://en.wikipedia.org/wiki/Katz's_back-off_model">Katz Backoff</a> method, which provides a conditional probability for a word given that word's history (the words preceding it). The equation takes the following form:</small>

<center><img src="images/Katz Formula.png"></center>

<div class="smallest_text">
<p>
where:<br>

<span style="font-weight:bold"><em>C(x)</em> =</span> the number of times a phrase <em>x</em> occurs in the training set.<br>

<span style="font-weight:bold"><em>w<sub>i</sub></em> =</span> the <em>i</em>th word in the given context.<br>

<span style="font-weight:bold"><em>k</em> =</span> a minimum frequency threshold for a probability to be accepted. I've set this threshold at >=2.<br>

<span style="font-weight:bold"><em>d</em> =</span> the discounted probability density, estimated using the <a href="https://en.wikipedia.org/wiki/Good%E2%80%93Turing_frequency_estimation">Good-Turing frequency estimation</a>. The goal is to estimate how many words are not included in your dataset, and to adjust the conditional probabilities accordingly.<br>

<span style="font-weight:bold"><em>&alpha;</em> =</span> the discounted probability density of all higher order n-grams.</p>
</div>


The Model -- Candidate List
========================================================
<div class="small_text">
<p>
The user will input a text phrase, which will then be processed using the same steps I used to process the training corpora, as described on slide 2 (The Goal & Corpus Creation).<br><br>

The Katz Backoff method requires you to feed in specific words in order to find conditional probabilities. To do this, I take the user's last word typed and find all matches in the 2-gram frequency lookup table. This ensures that no potential words are left out, because any possible 3 or 4-gram phrases will necessarily also show up in the 2-gram table. The result is a list of all possible "candidates."<br><br>

If the user's most recent word doesn't show up as the beginning word in any of the 2-gram phrases, I find the latest word in the user's inputted phrase that does, and use that to create a list of potential words to feed into the algorithm.
</p>
</div>

The Model -- Prediction
========================================================
<div class="small_text">
<p>
Once I have my list of possible words, I want to assign each candidate a probability.<br><br>

To do this I apply the Katz-Backoff method, which will attempt to look up the user's phrase in the highest possible n-gram table. For instance, if the user types in <em>"Thanks for the"</em>, the model will recognize that the user has provided 3 words, so it will attempt to look up that phrase from the 4-gram table.<br><br>

If found, it will assign a probability to each of the potential terminating words. Remember, these probabilities will be <em>discounted</em> by the Good-Turing frequency estimation, so as not to be overconfident about the probabilities. If there is only one record in the 4-gram table starting with <em>"Thanks for the..."</em>, that doesn't mean it should be assigned a 100% probability, because it's possible the word the user has in mind isn't included in the dataset. Good-Turing is used to account for that, which facilitates the possibility for a lower order n-gram to overrule a rare higher order n-gram prediction.<br><br>

The model will then move on to the lower order n-grams, using all of the same steps, with one exception: any probabilities found using lower order n-grams are adjusted down by the probability density left over from the higher order n-grams.
</p>
</div>

Instructions and Additional Info
========================================================
<small>
The application can be found <a href="https://jeremybowyer.shinyapps.io/Text_Prediction/">on Shinyapps.io</a>.

To use it, select the "Application" tab at the top of the screen, then type a phrase in the box. After a few moments, a table and corresponding word cloud will be provided for the top 10 most likely words.

*Note: The app may require a few seconds to load up initially, but each calculation should be fairly swift.*

To view all of the code used to create the look up tables, as well as the functions created for running the model, visit my <a href="https://github.com/JeremyBowyer/Capstone-Project">GitHub Repository</a>.
</small>

