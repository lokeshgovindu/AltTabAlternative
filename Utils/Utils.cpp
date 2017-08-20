// Utils.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "Utils.h"
#include "fuzzywuzzy.h"

#include <iostream>

#define BUFFER_SIZE		1024


std::string ToLower(const char* s) {
	std::string ret;
	for (int i = 0; s[i] != '\0'; ++i) {
		if (isupper(s[i])) {
			ret += tolower(s[i]);
		}
		else {
			ret += s[i];
		}
	}
	return ret;
}


std::string ToNarrow(const wchar_t* szBufW) {
	char szBuf[BUFFER_SIZE];
	size_t count;
	errno_t err;

	err = wcstombs_s(&count, szBuf, (size_t)BUFFER_SIZE, szBufW, (size_t)BUFFER_SIZE);
	if (err != 0) {
		throw std::exception("Failed to convert to a multibyte character string.");
	}
	return ::ToLower(szBuf);
}


double GetRatioA(const char* s1, const char* s2)
{
	//printf("s1 = [%s], s2 = [%s]\n", s1, s2);
	return ::ratio(ToLower(s1), ToLower(s2));
}


double GetPartialRatioA(const char* s1, const char* s2)
{
	//printf("s1 = [%s], s2 = [%s]\n", s1, s2);
	return ::partial_ratio(ToLower(s1), ToLower(s2));
}


double GetRatioW(const wchar_t* s1, const wchar_t* s2)
{
	try {
		//wprintf(L"s1 = [%s], s2 = [%s]\n", s1, s2);
		return ::ratio(ToNarrow(s1), ToNarrow(s2));
	}
	catch (...) {
		return 0.0;
	}
}


struct ScopedTimer
{
	ScopedTimer() {
		QueryPerformanceCounter(&m_tStartTime);
	}

	~ScopedTimer() {
		QueryPerformanceCounter(&m_tStopTime);
		QueryPerformanceFrequency(&m_tFrequency);
		m_Elapsed = (double)(m_tStopTime.QuadPart - m_tStartTime.QuadPart) / (double)m_tFrequency.QuadPart;

		printf_s("Elapsed : %f\n", m_Elapsed);
	}

private:

	LARGE_INTEGER	m_tStartTime;
	LARGE_INTEGER	m_tStopTime;
	LARGE_INTEGER	m_tFrequency;
	std::string		m_Started;
	std::string		m_Ended;
	double			m_Elapsed;
	std::string		m_Name;
};

double GetPartialRatioW(const wchar_t* s1, const wchar_t* s2)
{
	//ScopedTimer st;
	try {
		//wprintf(L"s1 = [%s], s2 = [%s]\n", s1, s2);
		//printf("s1 = [%s], s2 = [%s]\n", ToNarrow(s1).c_str(), ToNarrow(s2).c_str());
		return partial_ratio(ToNarrow(s1), ToNarrow(s2));
	}
	catch (...) {
		return 0.0;
	}
}
