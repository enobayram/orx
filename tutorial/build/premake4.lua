-- This premake script should be used with orx-customized version of premake4.
-- Its Hg repository can be found at https://bitbucket.org/orx/premake-stable.
-- A copy, including binaries, can also be found in the extern/premake folder.

--
-- Globals
--

function islinux64 ()
    local pipe    = io.popen ("uname -m")
    local content = pipe:read ('*a')
    pipe:close ()

    local t64 =
    {
        'x86_64',
        'ia64',
        'amd64',
        'powerpc64',
        'sparc64'
    }

    for i, v in ipairs (t64) do
        if content:find (v) then
            return true
        end
    end

    return false
end

function initconfigurations ()
    return
    {
        "Debug",
        "Profile",
        "Release"
    }
end

function initplatforms ()
    if os.is ("windows") then
        if string.lower(_ACTION) == "vs2013" then
            return
            {
                "x64",
                "x32"
            }
        else
            return
            {
                "Native"
            }
        end
    elseif os.is ("linux") then
        if islinux64 () then
            return
            {
                "x64",
                "x32"
            }
        else
            return
            {
                "x32",
                "x64"
            }
        end
    elseif os.is ("macosx") then
        if string.find(string.lower(_ACTION), "xcode") then
            return
            {
                "Universal"
            }
        else
            return
            {
                "x32", "x64"
            }
        end
    end
end

function defaultaction (name, action)
   if os.is (name) then
      _ACTION = _ACTION or action
   end
end

defaultaction ("windows", "vs2013")
defaultaction ("linux", "gmake")
defaultaction ("macosx", "gmake")

newoption
{
    trigger = "to",
    value   = "path",
    description = "Set the output location for the generated files"
}

if os.is ("macosx") then
    osname = "mac"
else
    osname = os.get()
end

destination = _OPTIONS["to"] or "./" .. osname .. "/" .. _ACTION
copybase = path.rebase ("..", os.getcwd (), os.getcwd () .. "/" .. destination)


--
-- Solution: orx
--

solution "Tutorial"

    language ("C")

    location (destination)

    kind ("ConsoleApp")

    configurations
    {
        initconfigurations ()
    }

    platforms
    {
        initplatforms ()
    }

    includedirs
    {
        "../include",
        "../../code/include"
    }

    configuration{"not macosx"}
        libdirs{"../lib"}
    configuration{}

    libdirs
    {
        "../../code/lib/dynamic"
    }

    targetdir ("../bin")

    flags
    {
        "NoPCH",
        "NoManifest",
        "FloatFast",
        "NoNativeWChar",
        "NoExceptions",
        "NoIncrementalLink",
        "NoEditAndContinue",
        "NoMinimalRebuild",
        "Symbols",
        "StaticRuntime"
    }

    configuration {"not vs2013"}
        flags {"EnableSSE2"}

    configuration {"not x64"}
        flags {"EnableSSE2"}

    configuration {"not windows"}
        flags {"Unicode"}

    configuration {"*Debug*"}
        defines {"__orxDEBUG__"}
        links {"orxd"}

    configuration {"*Profile*"}
        defines {"__orxPROFILER__"}
        flags {"Optimize", "NoRTTI"}
        links {"orxp"}

    configuration {"*Release*"}
        flags {"Optimize", "NoRTTI"}
        links {"orx"}


-- Linux

    configuration {"linux"}
        linkoptions {"-Wl,-rpath ./", "-Wl,--export-dynamic"}
        links
        {
            "dl",
            "m",
            "rt"
        }

    -- This prevents an optimization bug from happening with some versions of gcc on linux
    configuration {"linux", "not *Debug*"}
        buildoptions {"-fschedule-insns"}


-- Mac OS X

    configuration {"macosx"}
        buildoptions
        {
            "-mmacosx-version-min=10.6",
            "-gdwarf-2",
            "-Wno-write-strings"
        }
        links
        {
            "Foundation.framework",
            "AppKit.framework"
        }
        linkoptions
        {
            "-mmacosx-version-min=10.6",
            "-dead_strip"
        }

    configuration {"macosx", "x32"}
        buildoptions
        {
            "-mfix-and-continue"
        }


-- Windows


--
-- Project: 01_Object
--

project "01_Object"

    files {"../src/01_Object.c"}


-- Linux

    configuration {"linux"}
        postbuildcommands {"$(shell [ -f " .. copybase .. "/../code/lib/dynamic/liborx.so ] && cp -f " .. copybase .. "/../code/lib/dynamic/liborx*.so " .. copybase .. "/bin)"}


-- Mac OS X

    configuration {"macosx"}
        postbuildcommands {"$(shell [ -f " .. copybase .. "/../code/lib/dynamic/liborx.dylib ] && cp -f " .. copybase .. "/../code/lib/dynamic/liborx*.dylib " .. copybase .. "/bin)"}


-- Windows

    configuration {"windows"}
        postbuildcommands {"cmd /c if exist " .. path.translate(copybase, "\\") .. "\\..\\code\\lib\\dynamic\\orx.dll copy /Y " .. path.translate(copybase, "\\") .. "\\..\\code\\lib\\dynamic\\orx*.dll " .. path.translate(copybase, "\\") .. "\\bin"}


--
-- Project: 02_Clock
--

project "02_Clock"

    files {"../src/02_Clock.c"}


--
-- Project: 03_Frame
--

project "03_Frame"

    files {"../src/03_Frame.c"}


--
-- Project: 04_Anim
--

project "04_Anim"

    files {"../src/04_Anim.c"}


--
-- Project: 05_Viewport
--

project "05_Viewport"

    files {"../src/05_Viewport.c"}


--
-- Project: 06_Sound
--

project "06_Sound"

    files {"../src/06_Sound.c"}


--
-- Project: 07_FX
--

project "07_FX"

    files {"../src/07_FX.c"}


--
-- Project: 08_Physics
--

project "08_Physics"

    files {"../src/08_Physics.c"}


--
-- Project: 09_Scrolling
--

project "09_Scrolling"

    files {"../src/09_Scrolling.c"}


--
-- Project: 10_Locale
--

project "10_Locale"

    language ("C++")

    files {"../src/10_Locale.cpp"}

    configuration {"windows", "vs*"}
        buildoptions {"/EHsc"}

--
-- Project: 11_Spawner
--

project "11_Spawner"

    files {"../src/11_Spawner.c"}


--
-- Project: 12_Lighting
--

project "12_Lighting"

    files {"../src/12_Lighting.c"}
