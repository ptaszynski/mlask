# mlask
[INTRODUCTION]

This is README for ML-Ask, or eMotive eLement and Expression Analysis system, ver. 3.1-4.3

[OVERVIEW]

ML-Ask, or eMotive eLement and Expression Analysis system, is a keyword-based language-dependent system for automatic affect annotation on utterances in Japanese. It uses a two-step procedure:
    1. Specifying whether a sentence is emotive, and
    2. Recognizing particular emotion types in utterances described as emotive.
The database of emotemes was hand-crafted and contains 907 emotemes, which include such groups of emotemes as interjections, mimetic expressions (gitaigo in Japanese), vulgar language, or emotive sentence markers. 
The emotive expression database is a collection of over two thousand expressions describing emotional states.
ML-Ask also implements the idea of Contextual Valence Shifters (CVS) for Japanese with 108 syntactic negation structures.
Finally, ML-Ask implements Russell’s two dimensional model of affect. The model assumes that all emotions can be represented in two dimensions: the valence (positive/negative) and activation (activated/deactivated).

[INSTALLATION]

1. Unpack the system repository (zipped file).

2. Make sure you are using the system under Linux. Performance under Windows and Mac is still not confirmed.

3. Install all dependencies:

    3.1 The Perl Programming Language (www.perl.org)

    3.2 MeCab: Yet Another Part-of-Speech and Morphological Analyzer (http://taku910.github.io/mecab/)

    3.3 MeCAB perl binding (http://taku910.github.io/mecab/bindings.html)

    3.4 RE2 regex engine (http://search.cpan.org/dist/re-engine-RE2/)

[USAGE]

To use on standard input, launch in command line as: "perl mlask[version_number].pl" or "perl mlask[version_number]-simple.pl"
To use on files, launch in command line as: "perl mlask[version_number].pl input_file.txt > output_file.txt" (or similarly with "-simple").
Using -h or -help option will diplay help message and exit the program.

[COPYRIGHTS AND CONTRIBUTIONS]

The system was developed by Michal Ptaszynski (ptaszynski@ieee.org), Pawel Dybala, Rafal Rzepka and Kenji Araki. 

Particural role of each contributor:
Michal Ptaszynski - main developer and a person representative for the system.
Pawel Dybala - created most of the code for the first version of ML-Ask (ML-Ask 1.0, also used in ML-Ask 2.0 and ML-Ask 3.0-3.1).
Rafal Rzepka - countless conceptual contributions.
Kenji Araki - boss of the Araki Lab at Hokkaido Univeristy Japan, in which works on the system has started.

[REFERENCES]

The ML-Ask system is described in detail in papers below. When using ML-Ask please add reference to either of these papers (or both if you like):

Original initial paper:

Michal Ptaszynski, Pawel Dybala, Rafal Rzepka and Kenji Araki, “Affecting Corpora: Experiments with Automatic Affect Annotation System - A Case Study of the 2channel Forum -”, In Proceedings of The Conference of the Pacific Association for Computational Linguistics (PACLING-09), September 1-4, 2009, Hokkaido University, Sapporo, Japan, pp. 223-228.

Final release of the system:

Ptaszynski, M., Dybala, P., Rzepka, R., Araki, K., & Masui, F. (2017). ML-Ask: Open source affect analysis software for textual input in Japanese. Journal of Open Research Software, 5(1), 16-16.
https://doi.org/10.5334/jors.149
https://openresearchsoftware.metajnl.com/articles/10.5334/jors.149

Final release of emotion expression dictionary expanded using scientifically backed methods:

Wang, L., Isomura, S., Ptaszynski, M., Dybala, P., Urabe, Y., Rzepka, R., & Masui, F. (2024). The Limits of Words: Expanding a Word-Based Emotion Analysis System with Multiple Emotion Dictionaries and the Automatic Extraction of Emotive Expressions. Applied Sciences, 14(11), 4439.
https://doi.org/10.3390/app14114439
https://www.mdpi.com/2076-3417/14/11/4439


[BUGS AND COMMENTS]

Please report any comments and bugs to: ptaszynski@ieee.org

