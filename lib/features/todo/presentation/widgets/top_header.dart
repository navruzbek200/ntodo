import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/bloc/logout/logout_bloc.dart';
import '../../../auth/presentation/bloc/logout/logout_state.dart';

class TodoHeader extends StatelessWidget {
  final String username;
  final bool selecting;
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onCloseSelect;
  final VoidCallback onLogout;

  const TodoHeader({
    super.key,
    required this.username,
    required this.selecting,
    required this.selectedCount,
    required this.onDelete,
    required this.onCloseSelect,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Stack(
            children: [
              Container(color: AppColors.buttonColor),
              const Center(
                child: Text(
                  'My Todo List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 350, top: 57),
                child: BlocBuilder<LogoutBloc, LogoutState>(
                  builder: (context, state) {
                    final loading = state is LogoutLoading;

                    return GestureDetector(
                      onTap: loading ? null : onLogout,
                      child: loading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Image.asset(
                        'assets/icons/logout_icon.png',
                        width: 22,
                        height: 22,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: selecting
                    ? Row(
                  children: [
                    Text(
                      '$selectedCount selected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onCloseSelect,
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF8F98A8),
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(color: Color(0xFF2E2E2E)),
                        children: [
                          const TextSpan(
                            text: 'Welcome, ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: '$username.',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.buttonColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create tasks to achieve more.',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: GestureDetector(
                  onTap: onDelete,
                  child: Image.asset(
                    'assets/icons/delete_icon.png',
                    width: 22,
                    height: 22,
                    color: selecting
                        ? AppColors.buttonColor
                        : const Color(0xFF8F98A8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}