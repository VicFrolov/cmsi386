prereq(cmsi281,cmsi185).  % Data Structures depends on Computer Programming
prereq(cmsi282,cmsi281).  % Algorithms depends on Data Structures
prereq(cmsi284,cmsi281).  % Systems Programming depends on Data Structures
prereq(cmsi355,cmsi284).  % Networks and Internets depends on Systems Programming
prereq(cmsi386,cmsi284).  % Programming Languages depends on Systems Programming
prereq(cmsi387,cmsi284).  % Operating Systems depends on Systems Programming
prereq(cmsi485,cmsi385).  % Artificial Intelligence depends on Theory of Computation
prereq(cmsi485,cmsi386).  % Artificial Intelligence depends on Programming Languages
prereq(cmsi486,cmsi386).  % Intro to Database Systems depends on Programming Languages
prereq(cmsi486,cmsi387).  % Intro to Database Systems depends on Operating Systems