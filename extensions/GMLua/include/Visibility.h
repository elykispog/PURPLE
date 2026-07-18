#define GMLUA_DECLSPEC __attribute__((visibility("default")))

#ifdef _WIN32
#undef GMLUA_DECLSPEC
#if GMLUA_BUILD
#define GMLUA_DECLSPEC __declspec(dllexport)
#else
#define GMLUA_DECLSPEC __declspec(dllimport)
#endif
#endif