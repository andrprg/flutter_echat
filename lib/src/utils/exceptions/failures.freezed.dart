// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( AuthFailure value)?  auth,TResult Function( FirestoreFailure value)?  firestore,TResult Function( NotFoundFailure value)?  notFound,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case AuthFailure() when auth != null:
return auth(_that);case FirestoreFailure() when firestore != null:
return firestore(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( AuthFailure value)  auth,required TResult Function( FirestoreFailure value)  firestore,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case AuthFailure():
return auth(_that);case FirestoreFailure():
return firestore(_that);case NotFoundFailure():
return notFound(_that);case UnexpectedFailure():
return unexpected(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( AuthFailure value)?  auth,TResult? Function( FirestoreFailure value)?  firestore,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case AuthFailure() when auth != null:
return auth(_that);case FirestoreFailure() when firestore != null:
return firestore(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message)?  network,TResult Function( AuthFailureReason reason)?  auth,TResult Function( String code)?  firestore,TResult Function()?  notFound,TResult Function( Object error)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case AuthFailure() when auth != null:
return auth(_that.reason);case FirestoreFailure() when firestore != null:
return firestore(_that.code);case NotFoundFailure() when notFound != null:
return notFound();case UnexpectedFailure() when unexpected != null:
return unexpected(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message)  network,required TResult Function( AuthFailureReason reason)  auth,required TResult Function( String code)  firestore,required TResult Function()  notFound,required TResult Function( Object error)  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that.message);case AuthFailure():
return auth(_that.reason);case FirestoreFailure():
return firestore(_that.code);case NotFoundFailure():
return notFound();case UnexpectedFailure():
return unexpected(_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message)?  network,TResult? Function( AuthFailureReason reason)?  auth,TResult? Function( String code)?  firestore,TResult? Function()?  notFound,TResult? Function( Object error)?  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case AuthFailure() when auth != null:
return auth(_that.reason);case FirestoreFailure() when firestore != null:
return firestore(_that.code);case NotFoundFailure() when notFound != null:
return notFound();case UnexpectedFailure() when unexpected != null:
return unexpected(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure extends Failure {
  const NetworkFailure([this.message]): super._();
  

 final  String? message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'Failure.network(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(NetworkFailure(
freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AuthFailure extends Failure {
  const AuthFailure(this.reason): super._();
  

 final  AuthFailureReason reason;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'Failure.auth(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@useResult
$Res call({
 AuthFailureReason reason
});




}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(AuthFailure(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as AuthFailureReason,
  ));
}


}

/// @nodoc


class FirestoreFailure extends Failure {
  const FirestoreFailure(this.code): super._();
  

 final  String code;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirestoreFailureCopyWith<FirestoreFailure> get copyWith => _$FirestoreFailureCopyWithImpl<FirestoreFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FirestoreFailure&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode {
    return Object.hash(runtimeType,code);
}

@override
String toString() {
    return 'Failure.firestore(code: $code)';
}


}

/// @nodoc
abstract mixin class $FirestoreFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $FirestoreFailureCopyWith(FirestoreFailure value, $Res Function(FirestoreFailure) _then) = _$FirestoreFailureCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$FirestoreFailureCopyWithImpl<$Res>
    implements $FirestoreFailureCopyWith<$Res> {
  _$FirestoreFailureCopyWithImpl(this._self, this._then);

  final FirestoreFailure _self;
  final $Res Function(FirestoreFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(FirestoreFailure(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NotFoundFailure extends Failure {
  const NotFoundFailure(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Failure.notFound()';
}


}




/// @nodoc


class UnexpectedFailure extends Failure {
  const UnexpectedFailure(this.error): super._();
  

 final  Object error;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'Failure.unexpected(error: $error)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@useResult
$Res call({
 Object error
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(UnexpectedFailure(
null == error ? _self.error : error ,
  ));
}


}

// dart format on
