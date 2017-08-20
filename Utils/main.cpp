


#include <iostream>
#include "FuzzyWuzzy.h"

using namespace std;

#include "e:/Labs/C++/logo.h"

LOGO_NS_USE;

int main() {

	string w1 = "Healed";
	vector<string> vs = { "Healed", "Heard", "Healthy", "Help", "Herded", "Sealed", "Sold" };

	FORC(i, vs) {
		double ret = FuzzyWuzzy::ratio(vs[i], w1);
		LGPRINT3(vs[i], w1, ret);
	}

	LGPRINT(FuzzyWuzzy::ratio("testc", "testc"));
	LGPRINT(FuzzyWuzzy::ratio("testc", "tesct"));

	{
		string a = "tsetc";
		string b = R"(solution: [e:/labs/c++/testcpp2013/testcpp2013.sln],  config: [debug|win32],  file: [e:/labs/c++/testcpp2013/testcpp2013.cpp] - microsoft visual studio 2013 ultimate 12.0)";

		LGPRINT(FuzzyWuzzy::partial_ratio("testc", b));
		LGPRINT(FuzzyWuzzy::partial_ratio("tesct", b));
		LGPRINT(FuzzyWuzzy::partial_ratio("tecst", b));
	}

	return 0;
}