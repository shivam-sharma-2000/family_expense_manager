/// Represents the user's current authentication or authorization state.
///
/// - [unauthenticated]: User has not logged in yet.
/// - [unauthorized]: User is logged in but has not selected a team (role not assigned).
/// - All other values are valid roles authorized to access specific areas.
enum UserRole {
  unknown,

  /// User is not logged in.
  unauthenticated,

  /// User is logged in.
  authenticated,
}
