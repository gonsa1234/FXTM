import 'package:bcrypt/bcrypt.dart'; // Importing the bcrypt library for password hashing and validation.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore to interact with the Firebase database.
import 'dart:developer' as dev; // Importing 'dart:developer' for dev tools.

class UserService {
  /// Creates a user in the Firestore database.
  /// Implementation:
  /// - This function should be called when the user submits the "Sign Up" form.
  /// - Before creating the user, it checks if the username is available
  ///   and if the password is strong enough.

  Future<void> createUser(String username, String name, String password) async {
    // Reference to the 'Users' collection in Firestore.
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Check if the username is available.
    if (!await isUsernameAvailable(username)) {
      dev.log("Username is already in use.");
      return;
    }

    // Check if the password meets strength requirements.
    if (!isPasswordStrong(password)) {
      dev.log("Password does not meet strength criteria.");
      return;
    }

    // Generate a secure hash of the password before saving it.
    String hashedPassword = generatePasswordHash(password);

    // Add the new user document to the Firestore 'Users' collection.
    await usersCollection.add({
      'username': username,
      'name': name,
      'password': hashedPassword,
    });

    dev.log("User created successfully!");
  }

  /// Deletes a user from the Firestore database.
  /// Implementation:
  /// - This function should be called when an admin or user
  ///   decides to delete their account.
  Future<void> deleteUser(String userId) async {
    // Reference to the 'Users' collection in Firestore.
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Delete the user document with the given userId.
    await usersCollection.doc(userId).delete();
    dev.log("User deleted successfully.");
  }

  /// Checks if a username is available in Firestore.
  /// Implementation:
  /// - This function should be triggered when the user types or submits a username
  ///   in the "Sign Up" form.
  /// - If the username is not available, show a message to the user.
  Future<bool> isUsernameAvailable(String username) async {
    // Reference to the 'Users' collection in Firestore.
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Query the Firestore collection for the given username.
    QuerySnapshot querySnapshot =
        await usersCollection.where('username', isEqualTo: username).get();

    // Return true if the username does not exist.
    return querySnapshot.docs.isEmpty;
  }

  /// Updates a user's username in Firestore.
  /// Implementation:
  /// - This function should be triggered when the user decides to update their username
  ///   from the profile settings page.
  Future<void> updateUsername(String userId, String newUsername) async {
    // Reference to the 'Users' collection in Firestore.
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Check if the new username is available.
    if (!await isUsernameAvailable(newUsername)) {
      dev.log("The username is already in use.");
      return;
    }

    // Update the username in the Firestore database.
    await usersCollection.doc(userId).update({'username': newUsername});
    dev.log("Username updated successfully.");
  }

  /// Generates a secure hash of a password for storage.
  /// Implementation:
  /// - Call this function before saving a user's password in the database.
  String generatePasswordHash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifies if a given password matches the stored hashed password.
  /// Implementation:
  /// - Use this function during login to check if the entered password is correct.
  bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  /// Validates if a password meets the security criteria.
  /// Implementation:
  /// - Use this function during the "Sign Up" and "Update Password" processes
  ///   to ensure the password is strong.
  bool isPasswordStrong(String password) {
    // Regular expression for password validation:
    // - At least 8 characters.
    // - At least one uppercase letter, one lowercase letter, one number, and one symbol.
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Updates a user's password in Firestore.
  /// Implementation:
  /// - This function should be triggered when the user changes their password
  ///   from the profile settings page.
  Future<void> updatePassword(String userId, String newPassword) async {
    // Reference to the 'Users' collection in Firestore.
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Validate the strength of the new password.
    if (!isPasswordStrong(newPassword)) {
      dev.log("The new password does not meet strength criteria.");
      return;
    }

    // Generate a secure hash of the new password.
    String hashedPassword = generatePasswordHash(newPassword);

    // Update the password in the Firestore database.
    await usersCollection.doc(userId).update({'password': hashedPassword});
    dev.log("Password updated successfully.");
  }

  bool isEmailValid(String email) {
    // Regular expression to validate email format
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  /// Checks if the email is available in the Firestore database.
  Future<bool> isEmailAvailable(String email) async {
    // Reference to the 'Users' collection in Firestore
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    // Query the database to check if the email exists
    QuerySnapshot querySnapshot =
        await usersCollection.where('email', isEqualTo: email).get();

    // If no documents are found, the email is available
    return querySnapshot.docs.isEmpty;
  }

  /// Combines validation and availability check.
  Future<bool> checkEmail(String email) async {
    // First, validate the email format
    if (!isEmailValid(email)) {
      dev.log("Invalid email format.");
      return false;
    }

    // Then, check if the email is available
    bool available = await isEmailAvailable(email);
    if (!available) {
      dev.log("Email is already in use.");
      return false;
    }

    dev.log("Email is valid and available.");
    return true;
  }
}
