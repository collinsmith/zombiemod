#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <logger>

#include "../lib/set_player_model/playermodel.inc"

#include "include/stocks/path_stocks.inc"
#include "include/stocks/precache_stocks.inc"

#include "include/zm/zm_classes.inc"
#include "include/zm/zombies.inc"

#if defined ZM_COMPILE_FOR_DEBUG
  #define DEBUG_PRECACHING
  #define DEBUG_APPLICATION
#else
  //#define DEBUG_PRECACHING
  //#define DEBUG_APPLICATION
#endif

#define EXTENSION_NAME "Class Player Models"
#define VERSION_STRING "1.0.0"

static Logger: logger = Invalid_Logger;
#pragma unused logger

public zm_onInit() {
  logger = zm_getLogger();
}

public zm_onInitExtension() {
  new name[32];
  formatex(name, charsmax(name), "[%L] %s", LANG_SERVER, ZM_NAME_SHORT, EXTENSION_NAME);

  new buildId[32];
  getBuildId(buildId, charsmax(buildId));
  register_plugin(name, buildId, "Tirant");
  zm_registerExtension(
      .name = EXTENSION_NAME,
      .version = buildId,
      .desc = "Applies player models for classes");
}

stock getBuildId(buildId[], len) {
  return formatex(buildId, len, "%s [%s]", VERSION_STRING, __DATE__);
}

public zm_onClassRegistered(const name[], const Class: class) {
  new model[32];
  zm_getClassProperty(class, ZM_CLASS_MODEL, model, charsmax(model));

  new path[256];
  BuildPlayerModelPath(path, charsmax(path), model, logger);
  precacheModel(path, logger);
}

public zm_onApply(const id) {
  new const Class: class = zm_getUserClass(id);
  if (!class) {
#if defined DEBUG_APPLICATION
    LoggerLogDebug(logger, "%N doesn't have a class, resetting", id);
#endif
    fm_reset_user_model(id);
    return;
  }

  static value[32];
  zm_getClassProperty(class, ZM_CLASS_MODEL, value, charsmax(value));

#if defined DEBUG_APPLICATION
  LoggerLogDebug(logger, "Changing player model of %N to \"%s\"", id, value);
#endif
  
  // TODO: Support custom player model indexes
  fm_set_user_model(id, value, false);
}
