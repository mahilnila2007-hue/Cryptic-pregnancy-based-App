import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../widgets/bottom_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPhoneController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController = TextEditingController();

  // Focus nodes to highlight active fields with animated glow
  final FocusNode _fnLoginEmail = FocusNode();
  final FocusNode _fnLoginPassword = FocusNode();
  final FocusNode _fnSignupName = FocusNode();
  final FocusNode _fnSignupEmail = FocusNode();
  final FocusNode _fnSignupPhone = FocusNode();
  final FocusNode _fnSignupPassword = FocusNode();
  final FocusNode _fnSignupConfirmPassword = FocusNode();

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureSignupConfirmPassword = true;

  bool _rememberMe = true;
  bool _agreeTerms = true;

  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Rebuild when focus changes for smooth outline illumination
    _fnLoginEmail.addListener(() => setState(() {}));
    _fnLoginPassword.addListener(() => setState(() {}));
    _fnSignupName.addListener(() => setState(() {}));
    _fnSignupEmail.addListener(() => setState(() {}));
    _fnSignupPhone.addListener(() => setState(() {}));
    _fnSignupPassword.addListener(() => setState(() {}));
    _fnSignupConfirmPassword.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPhoneController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();

    _fnLoginEmail.dispose();
    _fnLoginPassword.dispose();
    _fnSignupName.dispose();
    _fnSignupEmail.dispose();
    _fnSignupPhone.dispose();
    _fnSignupPassword.dispose();
    _fnSignupConfirmPassword.dispose();
    super.dispose();
  }

  void _triggerLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isAuthenticating = true);

    // Provide a slick micro-feedback animation delay then proceed
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const SobiMainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient gradient orbs
          Positioned(
            top: -60,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.25),
                    AppColors.primaryLight.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.surface.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main Responsive Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 520 : double.infinity,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 36.0 : 22.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // TOP LOGO HERO BRANDING
                      _buildBrandingHeader(),

                      const SizedBox(height: 24),

                      // INTERACTIVE GLASS CARD CONTAINER
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.surface.withOpacity(0.4),
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          children: [
                            // INTERACTIVE TAB SELECTOR
                            _buildCustomTabSelector(),

                            const SizedBox(height: 24),

                            // TAB CONTENT (SIGN IN / SIGN UP)
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 300),
                              crossFadeState: _tabController.index == 0
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: _buildSignInSection(),
                              secondChild: _buildSignUpSection(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // QUICK / GUEST ACCESS
                      Center(
                        child: TextButton.icon(
                          onPressed: _triggerLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Explore Without Login',
                            style: TextStyle(
                              color: AppColors.primary.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BRANDING HEADER ---
  Widget _buildBrandingHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.favorite_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'SOBI',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Women Health Telemetry & Optical Screening',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // --- TAB SELECTOR ---
  Widget _buildCustomTabSelector() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.surface.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Sign In',
              icon: Icons.login_rounded,
              isSelected: _tabController.index == 0,
              onTap: () {
                setState(() => _tabController.animateTo(0));
              },
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: 'Sign Up',
              icon: Icons.person_add_outlined,
              isSelected: _tabController.index == 1,
              onTap: () {
                setState(() => _tabController.animateTo(1));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SIGN IN SECTION ---
  Widget _buildSignInSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: _loginEmailController,
          focusNode: _fnLoginEmail,
          label: 'Email or Mobile Number',
          hint: 'user@example.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _loginPasswordController,
          focusNode: _fnLoginPassword,
          label: 'Password',
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
        ),
        const SizedBox(height: 10),

        // Remember me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) =>
                          setState(() => _rememberMe = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _triggerLogin,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Sign In Action Button
        _buildActionButton(
          label: 'Sign In to SOBI',
          icon: Icons.login_rounded,
          isLoading: _isAuthenticating,
          onPressed: _triggerLogin,
        ),

        const SizedBox(height: 20),

        // Social / Quick Sign-In Buttons
        _buildSocialLoginRow(),
      ],
    );
  }

  // --- SIGN UP SECTION ---
  Widget _buildSignUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: _signupNameController,
          focusNode: _fnSignupName,
          label: 'Full Name',
          hint: 'e.g. Dr. Sarah Jenkins',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _signupEmailController,
          focusNode: _fnSignupEmail,
          label: 'Email Address',
          hint: 'sarah@health.org',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _signupPhoneController,
          focusNode: _fnSignupPhone,
          label: 'Phone Number (Optional)',
          hint: '+1 (555) 019-2834',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _signupPasswordController,
          focusNode: _fnSignupPassword,
          label: 'Password',
          hint: 'Create strong password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureSignupPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignupPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => setState(
                () => _obscureSignupPassword = !_obscureSignupPassword),
          ),
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _signupConfirmPasswordController,
          focusNode: _fnSignupConfirmPassword,
          label: 'Confirm Password',
          hint: 'Repeat your password',
          icon: Icons.verified_user_outlined,
          obscureText: _obscureSignupConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignupConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => setState(() =>
                _obscureSignupConfirmPassword = !_obscureSignupConfirmPassword),
          ),
        ),
        const SizedBox(height: 12),

        // Terms Checkbox
        GestureDetector(
          onTap: () => setState(() => _agreeTerms = !_agreeTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreeTerms,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) => setState(() => _agreeTerms = val ?? true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I agree to the Health Data Privacy & Research Terms',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Sign Up Action Button
        _buildActionButton(
          label: 'Create SOBI Account',
          icon: Icons.arrow_forward_rounded,
          isLoading: _isAuthenticating,
          onPressed: _triggerLogin,
        ),

        const SizedBox(height: 16),
        _buildSocialLoginRow(),
      ],
    );
  }

  // --- INTERACTIVE FORM INPUT FIELD ---
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasFocus = focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: hasFocus ? AppColors.primary : AppColors.nearBlack.withOpacity(0.8),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasFocus ? Colors.white : AppColors.background.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFocus
                  ? AppColors.primary
                  : AppColors.surface.withOpacity(0.4),
              width: hasFocus ? 1.6 : 1.0,
            ),
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.nearBlack,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                icon,
                color: hasFocus ? AppColors.primary : Colors.grey[500],
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- INTERACTIVE ACTION BUTTON ---
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.38),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // --- SOCIAL / ONE-CLICK AUTH ROW ---
  Widget _buildSocialLoginRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR QUICK CONNECT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialPill(
              label: 'Google Health',
              icon: Icons.health_and_safety_outlined,
              onTap: _triggerLogin,
            ),
            const SizedBox(width: 12),
            _buildSocialPill(
              label: 'Clinic ID',
              icon: Icons.badge_outlined,
              onTap: _triggerLogin,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialPill({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.nearBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
