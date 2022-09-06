import 'package:arcus_engine/helpers/utils.dart';

/// Timer object tracks how long has passed since it was set
/// @example
/// let a = new Timer;    // creates a timer that is not set
/// a.set(3);             // sets the timer to 3 seconds
///
/// let b = new Timer(1); // creates a timer with 1 second left
/// b.unset();            // unsets the timer
class CustomTimer {
  double? time;
  double? originalTime = 0;
  double setTime = 0;
  /** Create a timer object set time passed in
     *  @param {Number} [timeLeft] - How much time left before the timer elapses in seconds */
  CustomTimer(timeLeft) {
    time = timeLeft == null ? null : time! + timeLeft;
    setTime = timeLeft;
    originalTime = time;
  }

  /** Set the timer with seconds passed in
     *  @param {Number} [timeLeft=0] - How much time left before the timer is elapsed in seconds */
  set({timeLeft = 0}) {
    if (time != null) {
      time = time! + timeLeft;
      setTime = timeLeft;
    }
  }

  /// Unset the timer */
  unset() {
    time = null;
  }

  /** Returns true if set
     * @return {Boolean} */
  isSet() {
    return time != null;
  }

  /** Returns true if set and has not elapsed
     * @return {Boolean} */
  active() {
    if (time != null && originalTime != null) {
      return time! <= originalTime!;
    } else {
      return null;
    }
  }

  /** Returns true if set and elapsed
     * @return {Boolean} */
  elapsed() {
    if (time != null && originalTime != null) {
      return time! > originalTime!;
    } else {
      return null;
    }
  }

  /** Get how long since elapsed, returns 0 if not set (returns negative if currently active)
     * @return {Number} */
  get() {
    if (time != null && originalTime != null) {
      return this.isSet() ? originalTime! - time! : 0;
    } else {
      return null;
    }
  }

  /** Get percentage elapsed based on time it was set to, returns 0 if not set
     * @return {Number} */
  getPercent() {
    if (time != null && originalTime != null) {
      return this.isSet() ? Utils.shared.percent(originalTime! - time!, min: setTime, max: 0) : 0;
    } else
      return 0;
  }

  /** Returns this timer expressed as a string
     * @return {String} */
  toString() {
    return this.unset() ? 'unset' : (this.get()).abs() + ' seconds ' + (get() < 0 ? 'before' : 'after');
  }
}
